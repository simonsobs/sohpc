#!/bin/bash

show_help () {
    echo "" >&2
    echo "Usage:  $0" >&2
    echo "    -c <config>" >&2
    echo "    -p <prefix>" >&2
    echo "    [-v <version>]" >&2
    echo "" >&2
    echo "    Generate an install script" >&2
    echo "" >&2
    echo "    The name of the config and the install prefix are required." >&2
    echo "    If a version string is not specified, the current git version" >&2
    echo "    of this repository is used." >&2
    echo "" >&2
    echo "" >&2
}

prefix=""
config=""
version=""

while getopts ":c:p:v:" opt; do
    case $opt in
        c)
            config=$OPTARG
            ;;
        p)
            prefix=$OPTARG
            ;;
        v)
            version=$OPTARG
            ;;
        \?)
            show_help
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            show_help
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

if [ "x${config}" = "x" ]; then
    show_help
    exit 1
fi

is_docker="no"
if [[ ${config} =~ .*docker.* ]]; then
    is_docker="yes"
fi

if [ "x${prefix}" = "x" ]; then
    if [ "${is_docker}" = "no" ]; then
        show_help
        exit 1
    else
        prefix="NONE"
    fi
fi

if [ "x${version}" == "x" ]; then
    if [ "${is_docker}" = "no" ]; then
        if [ "x$(which git)" = "x" ]; then
            echo "No version specified and git not available"
            exit 1
        fi
        gitdesc=$(git describe --tags --dirty --always | cut -d "-" -f 1)
        gitcnt=$(git rev-list --count HEAD)
        version="${gitdesc}.dev${gitcnt}"
    else
        version="none"
    fi
fi

moduledir="${prefix}/modulefiles"

# These tools assume that cmbenv is already loaded
if [ "${is_docker}" = "no" ]; then
    if [ "x${CMBENV_ROOT}" = "x" ]; then
        echo "Load the cmbenv tools before running this script."
        exit 1
    fi
fi

# get the absolute path to the directory with this script
pushd $(dirname $0) > /dev/null
topdir=$(pwd -P)
popd > /dev/null

conf_file="${topdir}/configs/${config}"

script="install_${config}"

eval "${topdir}/tools/gen_script.sh" "install.in" "${conf_file}" \
    "${script}" "${prefix}" "${version}" "${moduledir}"

exit 0
