#!/bin/bash

# The current so-env version
version=$1

# The install prefix
prefix=$2

# The python version
pyversion=$3

# Top level cmbenv git checkout
pushd $(dirname $0) > /dev/null 2>&1
topdir=$(dirname $(pwd))
popd > /dev/null 2>&1

# The outputs
outfile="${prefix}/bin/so-env"
rm -f "${outfile}"

# Create list of variable substitutions to apply

confsub="-e 's#@PREFIX@#${prefix}#g'"
confsub="${confsub} -e 's#@VERSION@#${version}#g'"
confsub="${confsub} -e 's#@PYVERSION@#${pyversion}#g'"

# Process the template

while IFS='' read -r line || [[ -n "${line}" ]]; do
    echo "${line}" | eval sed ${confsub} >> "${outfile}"
done < "${topdir}/so-env.in"
