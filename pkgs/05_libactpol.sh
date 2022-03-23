#!/bin/bash

pkg="libactpol"
version=c0c1647ad62b418f34fe38eb73168d4f2e13ff6f
psrc=${pkg}-${version}
pfile=${psrc}.tar.gz

fetched=$(eval "@TOP_DIR@/tools/fetch_check.sh" https://github.com/ACTCollaboration/libactpol/archive/${version}.tar.gz ${pfile})

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
    && sed -i -e 's/AC_FUNC_MALLOC/\#AC_FUNC_MALLOC/g' configure.ac \
    && autoreconf -i > ${log} 2>&1 \
    && CC="@CC@" CFLAGS="@CFLAGS@" \
    ./configure --enable-shared --disable-oldact \
    --disable-slalib --prefix="@PREFIX@" >> ${log} 2>&1 \
    && CC="@CC@" FC="@FC@" PREFIX="@PREFIX@" make >> ${log} 2>&1 \
    && CC="@CC@" FC="@FC@" PREFIX="@PREFIX@" make install >> ${log} 2>&1

if [ $? -ne 0 ]; then
    echo "Failed to build ${pkg}" >&2
    exit 1
fi

echo "Finished building ${pkg}" >&2
exit 0
