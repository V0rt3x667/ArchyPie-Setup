#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-swanstation"
rp_module_desc="Sony Playstation Libretro Core"
rp_module_help="ROM Extensions: .bin .chd .cue .ecm .exe .img .iso .m3u .mds .pbp .psexe .psf\n\nCopy PlayStation ROMs To: ${romdir}/psx\n\nCopy BIOS Files:\n\nscph5500.bin\nscph5501.bin\nscph5502.bin\n\nTo: ${biosdir}/psx"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/swanstation/main/LICENSE"
rp_module_section="exp"
rp_module_repo="git https://github.com/libretro/swanstation main"
rp_module_flags=""

function sources_lr-swanstation() {
    gitPullOrClone
}

function build_lr-swanstation() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/swanstation_libretro.so"
}

function install_lr-swanstation() {
    md_ret_files=('build/swanstation_libretro.so')
}

function configure_lr-swanstation() {
    mkRomDir "psx"

    isPlatform "rpi" && setRetroArchCoreOption "swanstation_GPU.Renderer" "Software"

    defaultRAConfig "psx" "system_directory" "${biosdir}/psx"

    addEmulator 0 "${md_id}" "psx" "${md_inst}/swanstation_libretro.so" 

    addSystem "psx"
}
