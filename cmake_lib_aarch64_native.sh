#!/bin/bash
# Build metaRTC natively on an aarch64 Linux machine (e.g. Parallels ARM64 VM)
# Does NOT use a cross-compiler toolchain file - cmake will pick up the native gcc.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

Yang_Moc=2    # 2 = ARM, activates ARM code paths in metaRTC source
Yang_Bit=64
Yang_Pic=1    # position-independent code

NPROC=$(nproc 2>/dev/null || echo 4)

mkdir -p bin/lib_debug

build_module() {
    local module=$1
    local libname=$2
    echo ""
    echo "=========================================="
    echo "  Building $libname"
    echo "=========================================="
    cd "$SCRIPT_DIR/$module"
    rm -rf build
    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DYang_Bit=$Yang_Bit \
          -DYang_Moc=$Yang_Moc \
          -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
          ..
    make -j$NPROC
    cp "./${libname}.a" "$SCRIPT_DIR/bin/lib_debug/"
    echo "  -> $libname.a copied to bin/lib_debug/"
    cd "$SCRIPT_DIR"
}

build_module libyangutil8    libyangutil8
build_module libmetartccore8 libmetartccore8
build_module libyangwhip8    libyangwhip8

echo ""
echo "=========================================="
echo "  All done. Libraries in bin/lib_debug/:"
ls "$SCRIPT_DIR/bin/lib_debug/"
echo "=========================================="
