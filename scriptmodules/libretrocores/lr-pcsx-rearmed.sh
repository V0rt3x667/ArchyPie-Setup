#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-pcsx-rearmed"
rp_module_desc="Sony PlayStation Libretro Core"
rp_module_help="ROM Extensions: .bin .cbn .chd .cue .img .m3u .mdf .pbp .toc\n\nCopy PSX ROMs To: ${romdir}/psx\n\nCopy BIOS Files:\n\nscph5500.bin\nscph5501.bin\nscph5502.bin\n\nTo: ${biosdir}/psx"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/pcsx_rearmed/master/COPYING"
rp_module_repo="git https://github.com/libretro/pcsx_rearmed master"
rp_module_section="opt arm=main"

function depends_lr-pcsx-rearmed() {
    local depends=('libpng')
    isPlatform "x11" && depends+=('libx11')
    getDepends "${depends[@]}"
}

function sources_lr-pcsx-rearmed() {
    gitPullOrClone
}

function build_lr-pcsx-rearmed() {
    local params=(THREAD_RENDERING=0)

    if isPlatform "arm"; then
        params+=(ARCH=arm DYNAREC=ari64)
    elif isPlatform "aarch64"; then
        params+=(ARCH=aarch64 DYNAREC=ari64)
    fi
    if isPlatform "neon"; then
        params+=(HAVE_NEON=1 HAVE_NEON_ASM=1 BUILTIN_GPU=neon)
    fi

    make -f Makefile.libretro "${params[@]}" clean
    make -f Makefile.libretro "${params[@]}"
    md_ret_require="${md_build}/pcsx_rearmed_libretro.so"
}

function install_lr-pcsx-rearmed() {
    md_ret_files=('pcsx_rearmed_libretro.so')
}

function configure_lr-pcsx-rearmed() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "psx"

        mkUserDir "${biosdir}/psx"
    fi

    defaultRAConfig "psx" "system_directory" "${biosdir}/psx"

    addEmulator 1 "${md_id}" "psx" "${md_inst}/pcsx_rearmed_libretro.so"

    addSystem "psx"
}
