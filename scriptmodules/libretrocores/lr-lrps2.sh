#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-lrps2"
rp_module_desc="Sony PlayStation 2 Libretro Core"
rp_module_help="ROM Extensions: .bin .chd .ciso .cso .cue .dump .elf .gz .img .iso .m3u .mdf .nrg\n\nCopy PS2 ROMs To: ${romdir}/ps2\n\nCopy BIOS Files: ps2-0230a-20080220, ps2-0230e-20080220 & ps2-0230j-20080220 To: ${biosdir}/ps2"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/LRPS2/main/COPYING.GPLv3"
rp_module_repo="git https://github.com/libretro/lrps2 main"
rp_module_section="exp"
rp_module_flags="!all x86"

function depends_lr-lrps2() {
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

function sources_lr-lrps2() {
    gitPullOrClone

    # Remove Hardcoded BIOS Directory
    sed -e "s|Path::Combine(system, \"pcsx2/bios\");|Path::Combine(system, \"\");|g" -i "${md_build}/libretro/main.cpp"

    # Disable 'ccache'
    sed -i '/ccache/d' ${md_build}/CMakeLists.txt

    # Fix Missing Includes
    sed -i '/include <vector>/a #include <string>' "${md_build}/pcsx2/CDVD/CDVDdiscReader.h"
    sed -i '/include <thread>/a #include <system_error>' "${md_build}/pcsx2/CDVD/CDVDdiscThread.cpp"
    sed -i '/include <vector>/a #include <cstdint>' "${md_build}/pcsx2/MemoryPatchDatabase.h"
}

function build_lr-lrps2() {
    # Will Not Build With 'clang' Or 'LTO' Enabled
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DLIBRETRO="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/pcsx2/pcsx2_libretro.so"
}

function install_lr-lrps2() {
    md_ret_files=('build/pcsx2/pcsx2_libretro.so')
}

function configure_lr-lrps2() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ps2"
        mkUserDir "${biosdir}/ps2"
        defaultRAConfig "ps2"
    fi

    addEmulator 0 "${md_id}" "ps2" "${md_inst}/pcsx2_libretro.so"

    addSystem "ps2"
}
