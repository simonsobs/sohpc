#!/bin/bash

pkg="sotodlib"
version=89e865e172ee6720b63710ea15f2f644148ef11c
psrc=${pkg}-${version}
pfile=${psrc}.tar.gz

fetched=$(eval "@TOP_DIR@/tools/fetch_check.sh" https://github.com/simonsobs/sotodlib/archive/${version}.tar.gz ${pfile})

if [ "x${fetched}" = "x" ]; then
    echo "Failed to fetch ${pkg}" >&2
    exit 1
fi

if [ "@DOCKER@" = "yes" ]; then
    log=/dev/stderr
else
    log="../log_${pkg}"
fi

echo "Building ${pkg}..." >&2

rm -rf ${psrc}
tar xzf ${fetched} \
    && cd ${psrc} \
    && python3 -m pip install --prefix "@PREFIX@" . > ${log} 2>&1

if [ $? -ne 0 ]; then
    echo "Failed to build ${pkg}" >&2
    exit 1
fi

echo "Finished building ${pkg}" >&2
exit 0
