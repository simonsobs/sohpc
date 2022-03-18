#!/bin/bash

# This is (for example) install.in
template=$1

# The config file definitions and package list
conffile=$2

# The output root of the install script
outroot=$3

# Runtime options
prefix=$4
version=$5
moddir=$6

# Top level directory
pushd $(dirname $0) > /dev/null
topdir=$(dirname $(pwd))
popd > /dev/null

# The outputs
outfile="${outroot}.sh"
outmod="${outfile}.mod"
outmodver="${outfile}.modver"
outinit="${outfile}.init"
outpkg="${outroot}_pkgs"
rm -f "${outfile}"
rm -f "${outmod}"
rm -f "${outmodver}"
rm -rf "${outpkg}"

mkdir -p "${outpkg}"


# Create list of variable substitutions from the input config file

confsub="-e 's#@CONFFILE@#${conffile}#g'"

# Get the major / minor python version
pyver=$(python3 --version 2>&1 | awk '{print $2}' | sed -e "s#\(.*\)\.\(.*\)\..*#\1.\2#")
confsub="${confsub} -e 's#@PYVERSION@#${pyver}#g'"

while IFS='' read -r line || [[ -n "${line}" ]]; do
    # is this line commented?
    comment=$(echo "${line}" | cut -c 1)
    if [ "${comment}" != "#" ]; then
        check=$(echo "${line}" | sed -e "s#.*=.*#=#")
        if [ "x${check}" = "x=" ]; then
            # get the variable and its value
            var=$(echo ${line} | sed -e "s#\([^=]*\)=.*#\1#" | awk '{print $1}')
            val=$(echo ${line} | sed -e "s#[^=]*= *\(.*\)#\1#")
            # add to list of substitutions
            confsub="${confsub} -e 's#@${var}@#${val}#g'"
        fi
    fi
done < "${conffile}"

# We add these predefined matches at the end- so that the config
# file can actually use these as well.

module_dir="${moddir}/so-env"

confsub="${confsub} -e 's#@SRCDIR@#${topdir}#g'"
confsub="${confsub} -e 's#@PREFIX@#${prefix}#g'"
confsub="${confsub} -e 's#@VERSION@#${version}#g'"
confsub="${confsub} -e 's#@MODULE_DIR@#${module_dir}#g'"
confsub="${confsub} -e 's#@TOP_DIR@#${topdir}#g'"

# Build up the lines to run the per-package install scripts.

pkgcom=""
for pkgfile in $(ls ${topdir}/pkgs | grep -e '\.sh$'); do
    # Copy the package file into place while applying the config.
    while IFS='' read -r pkgline || [[ -n "${pkgline}" ]]; do
        echo "${pkgline}" | eval sed ${confsub} >> "${topdir}/${outpkg}/${pkgfile}"
    done < "${topdir}/pkgs/${pkgfile}"
    chmod +x "${topdir}/${outpkg}/${pkgfile}"

    # Copy any patch file
    if [ -e "${topdir}/pkgs/${pkgfile}.patch" ]; then
        cp -a "${topdir}/pkgs/${pkgfile}.patch" "${topdir}/${outpkg}/"
    fi

    pcom="${topdir}/${outpkg}/${pkgfile}; if [ \$? -ne 0 ]; then echo \"FAILED\"; exit 1; fi"
    pkgcom+="${pcom}"$'\n'$'\n'
done

# Now process the input template, substituting the list of package install
# commands that we just built.

while IFS='' read -r line || [[ -n "${line}" ]]; do
    if [[ "${line}" =~ @PACKAGES@ ]]; then
        echo "${pkgcom}" >> "${outfile}"
    else
        echo "${line}" | eval sed ${confsub} >> "${outfile}"
    fi
done < "${template}"
chmod +x "${outfile}"

# Finally, create the module file and module version file for this config.
# Also create a shell snippet that can be sourced.

while IFS='' read -r line || [[ -n "${line}" ]]; do
    if [[ "${line}" =~ @modload@ ]]; then
        echo "module use ${CMBENV_ROOT}/modulefiles" >> "${outmod}"
        echo "if [ module-info mode load ] {" >> "${outmod}"
        echo "  if [ is-loaded cmbenv ] {" >> "${outmod}"
        echo "  } else {" >> "${outmod}"
        echo "    module load cmbenv" >> "${outmod}"
        echo "  }" >> "${outmod}"
        echo "}" >> "${outmod}"
    else
        echo "${line}" | eval sed ${confsub} >> "${outmod}"
    fi
done < "${topdir}/modulefile.in"

while IFS='' read -r line || [[ -n "${line}" ]]; do
    echo "${line}" | eval sed ${confsub} >> "${outmodver}"
done < "${topdir}/version.in"

echo "# Source this file from a Bourne-compatible shell to load" > "${outinit}"
echo "# this so_env installation into your environment:" >> "${outinit}"
echo "#" >> "${outinit}"
echo "#   %>  . path/to/so_env_init.sh" >> "${outinit}"
echo "#" >> "${outinit}"
echo "# Then do \"source so-env\" as usual." >> "${outinit}"
echo "#" >> "${outinit}"
echo "if [ \"x\${CMBENV_ROOT}\" = x ]; then" >> "${outinit}"
echo "  source ${CMBENV_ROOT}/cmbenv_init.sh" >> "${outinit}"
echo "fi" >> "${outinit}"
echo "export PATH=\"${prefix}/bin\":\${PATH}" >> "${outinit}"
