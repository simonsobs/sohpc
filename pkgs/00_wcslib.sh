#!/bin/bash

pkg="wcslib"
version=7.6
psrc=${pkg}-${version}
pfile=${psrc}.tar.bz2

fetched=$(eval "@TOP_DIR@/tools/fetch_check.sh" ftp://ftp.atnf.csiro.au/pub/software/wcslib/${pfile} ${pfile})

if [ "x${fetched}" = "x" ]; then
    echo "Failed to fetch ${pkg}" >&2
    exit 1
fi

log="../log_${pkg}"

echo "Building ${pkg}..." >&2

rm -rf ${psrc}
tar xjf ${fetched} \
    && cd ${psrc} \
    && CC="@CC@" CFLAGS="@CFLAGS@" ./configure \
    --prefix="@PREFIX@" > ${log} 2>&1 \
    && make -j @MAKEJ@ install >> ${log} 2>&1

if [ $? -ne 0 ]; then
    echo "Failed to build ${pkg}" >&2
    exit 1
fi

echo "Finished building ${pkg}" >&2
exit 0
