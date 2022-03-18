#!/bin/bash

pkg="libactpol_deps"
version=db0aee380dad503ba8fdf058d4d8075387100758
psrc=${pkg}-${version}
pfile=${psrc}.tar.gz

fetched=$(eval "@TOP_DIR@/tools/fetch_check.sh" https://github.com/ACTCollaboration/libactpol_deps/archive/${version}.tar.gz ${pfile})

if [ "x${fetched}" = "x" ]; then
    echo "Failed to fetch ${pkg}" >&2
    exit 1
fi

log="../log_${pkg}"

echo "Building ${pkg}..." >&2

rm -rf ${psrc}
tar xzf ${fetched} \
    && cd ${psrc}/sla_refro-moby2-1 \
    && CC="@CC@" FC="@FC@" PREFIX="@PREFIX@" make > ${log} 2>&1 \
    && CC="@CC@" FC="@FC@" PREFIX="@PREFIX@" make install >> ${log} 2>&1 \
    && cd ../sofa_20180130 \
    && PREFIX="@PREFIX@" make >> ${log} 2>&1 \
    && PREFIX="@PREFIX@" make install >> ${log} 2>&1 \
    && cd ../slim_v2_7_1-moby2-1 \
    && CC="@CC@" CFLAGS="@CFLAGS@" ./configure --prefix="@PREFIX@" --with-zzip >> ${log} 2>&1 \
    && make install >> ${log} 2>&1

if [ $? -ne 0 ]; then
    echo "Failed to build ${pkg}" >&2
    exit 1
fi

echo "Finished building ${pkg}" >&2
exit 0
