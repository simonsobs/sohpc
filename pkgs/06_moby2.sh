#!/bin/bash

pkg="moby2"
version=fd360a7352c88d3eb5195f5f0ea331ddc24e5e09
psrc=${pkg}-${version}
pfile=${psrc}.tar.gz

fetched=$(eval "@TOP_DIR@/tools/fetch_check.sh" https://github.com/ACTCollaboration/moby2/archive/${version}.tar.gz ${pfile})

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
    && patch -p1 < "@TOP_DIR@/pkgs/06_moby2.sh.patch" > ${log} 2>&1 \
    && python3 setup.py build >> ${log} 2>&1 \
    && python3 setup.py install --prefix "@PREFIX@" >> ${log} 2>&1

if [ $? -ne 0 ]; then
    echo "Failed to build ${pkg}" >&2
    exit 1
fi

echo "Finished building ${pkg}" >&2
exit 0
