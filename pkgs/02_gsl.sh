#!/bin/bash

pkg="gsl"
version=2.7.1
psrc=${pkg}-${version}
pfile=${psrc}.tar.gz

fetched=$(eval "@TOP_DIR@/tools/fetch_check.sh" https://ftpmirror.gnu.org/gsl/${pfile} ${pfile})

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
    && CC="@CC@" CFLAGS="@CFLAGS@" ./configure \
    --prefix="@PREFIX@" > ${log} 2>&1 \
    && make -j @MAKEJ@ >> ${log} 2>&1 \
    && make install >> ${log} 2>&1

if [ $? -ne 0 ]; then
    echo "Failed to build ${pkg}" >&2
    exit 1
fi

echo "Finished building ${pkg}" >&2
exit 0
