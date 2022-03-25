#!/bin/bash

pkg="so3g"
version=0.1.3
psrc=${pkg}-${version}
pfile=${psrc}.tar.gz

fetched=$(eval "@TOP_DIR@/tools/fetch_check.sh" https://github.com/simonsobs/so3g/archive/v${version}.tar.gz ${pfile})

if [ "x${fetched}" = "x" ]; then
    echo "Failed to fetch ${pkg}" >&2
    exit 1
fi

if [ "@DOCKER@" = "yes" ]; then
    log=/dev/stderr
else
    log="../../log_${pkg}"
fi

echo "Building ${pkg}..." >&2

blas=""
blas_static="${CMBENV_AUX_ROOT}/lib/libopenblas.a"
blas_shared="${CMBENV_AUX_ROOT}/lib/libopenblas.so"
if [ -e ${blas_static} ]; then
    blas="-DBLAS_LIBRARIES=${blas_static}"
else
    if [ -e ${blas_shared} ]; then
        blas="-DBLAS_LIBRARIES=${blas_shared}"
    fi
fi

rm -rf ${psrc}
tar xzf ${fetched} \
    && cd ${psrc} \
    && mkdir build \
    && cd build \
    && cmake \
    -DCMAKE_PREFIX_PATH=${CMBENV_AUX_ROOT}/spt3g/build \
    -DCMAKE_C_COMPILER="@CC@" \
    -DCMAKE_CXX_COMPILER="@CXX@" \
    -DCMAKE_C_FLAGS="@CFLAGS@" \
    -DCMAKE_CXX_FLAGS="@CXXFLAGS@" \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
    -DPYTHON_EXECUTABLE=$(which python3) ${blas} \
    -DCMAKE_INSTALL_PREFIX="@PREFIX@" \
    -DPYTHON_INSTALL_DEST="@PREFIX@/lib/python@PYVERSION@/site-packages" \
    .. > ${log} 2>&1 \
    && make -j @MAKEJ@ install >> ${log} 2>&1

if [ $? -ne 0 ]; then
    echo "Failed to build ${pkg}" >&2
    exit 1
fi

echo "Finished building ${pkg}" >&2
exit 0
