#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-pcsx2"
rp_module_desc="Sony PlayStation 2 Libretro Core"
rp_module_help="ROM Extensions: .elf .iso .ciso .chd .cso .bin .mdf .nrg .dump .gz .img .m3u"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/pcsx2/main/COPYING.GPLv3"
rp_module_repo="git https://github.com/libretro/pcsx2 main"
rp_module_section="exp"
rp_module_flags="!all x86"

function depends_lr-pcsx2() {
    local depends=(
        'cmake'
        'gcc-libs'
        'glibc'
        'libaio'
        'libglvnd'
        'ninja'
        'png++'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_lr-pcsx2() {
    gitPullOrClone
    # Set root directory under $biosdir
    sed 's|Path::Combine(system, "pcsx2/bios");|Path::Combine(system, "ps2/bios");|g' -i ./libretro/main.cpp
}

function build_lr-pcsx2() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DDISABLE_BUILD_DATE=ON \
        -DENABLE_TESTS=OFF \
        -DLIBRETRO=ON \
        -DREBUILD_SHADER=ON \
        -DXDG_STD=ON \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/pcsx2/pcsx2_libretro.so"
}

function install_lr-pcsx2() {
    md_ret_files=('build/pcsx2/pcsx2_libretro.so')
}

function configure_lr-pcsx2() {
    mkRomDir "ps2"

    mkUserDir "$biosdir/ps2"
    mkUserDir "$biosdir/ps2/bios"

    defaultRAConfig "ps2"

    addEmulator 0 "$md_id" "ps2" "$md_inst/pcsx2_libretro.so"
    addSystem "ps2"
}
