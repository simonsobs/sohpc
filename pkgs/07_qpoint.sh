#!/bin/bash

pkg="qpoint"
version=828126de9f195f88bfaf1996527f633382457461
psrc=${pkg}-${version}

if [ "@DOCKER@" = "yes" ]; then
    log=/dev/stderr
else
    log="../log_${pkg}"
fi

echo "Building ${pkg}..." >&2

rm -rf ${psrc}

git clone https://github.com/arahlin/qpoint.git ${psrc} \
    && cd ${psrc} \
    && git checkout -b so-env ${version} \
    && python3 setup.py build > ${log} 2>&1 \
    && python3 setup.py install --prefix "@PREFIX@" >> ${log} 2>&1

if [ $? -ne 0 ]; then
    echo "Failed to build ${pkg}" >&2
    exit 1
fi

echo "Finished building ${pkg}" >&2
exit 0
