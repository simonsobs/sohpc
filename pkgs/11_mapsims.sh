#!/bin/bash

pkg="mapsims"
version=9011f8cd0a5e1fa795f82dac15247264442b8a2f
psrc=${pkg}-${version}
pfile=${psrc}.tar.gz

fetched=$(eval "@TOP_DIR@/tools/fetch_check.sh" https://github.com/simonsobs/mapsims/archive/${version}.tar.gz ${pfile})

if [ "x${fetched}" = "x" ]; then
    echo "Failed to fetch ${pkg}" >&2
    exit 1
fi

log="../log_${pkg}"

echo "Pre-installing poetry..." >&2
python3 -m pip install --ignore-installed --prefix "@PREFIX@" poetry

echo "Building ${pkg}..." >&2

rm -rf ${psrc}
tar xzf ${fetched} \
    && cd ${psrc} \
    && python3 -m pip install --no-deps --prefix "@PREFIX@" . 2>&1 > ${log}

if [ $? -ne 0 ]; then
    echo "Failed to build ${pkg}" >&2
    exit 1
fi

echo "Finished building ${pkg}" >&2
exit 0
