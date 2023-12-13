#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-sameboy"
rp_module_desc="Nintendo Game Boy & Game Boy Color Core"
rp_module_help="ROM Extensions: .gb .gbc .zip\n\nCopy Game Boy ROMs To: ${romdir}/gb\n\nCopy Game Boy Color ROMs To: ${romdir}/gbc\n\nOPTIONAL: Copy BIOS File: dmg_boot.bin To: ${biosdir}/gb\nCopy BIOS File: cgb_boot.bin To: ${biosdir}/gbc"
rp_module_licence="MIT https://raw.githubusercontent.com/libretro/SameBoy/buildbot/LICENSE"
rp_module_repo="git https://github.com/libretro/SameBoy buildbot"
rp_module_section="opt"

function depends_lr-sameboy() {
    local depends=(
        'glibc'
        'libgl'
        'libglvnd'
        'rgbds'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_lr-sameboy() {
    gitPullOrClone
}

function build_lr-sameboy() {
    make -C libretro clean
    make -C libretro CONF=release
    md_ret_require="${md_build}/libretro/sameboy_libretro.so"
}

function install_lr-sameboy() {
    md_ret_files=(
        'libretro/sameboy_libretro.so'
        'LICENSE'
    )
}

function configure_lr-sameboy() {
    local systems=(
        'gb'
        'gbc'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            mkUserDir "${biosdir}/${system}"
            defaultRAConfig "${system}"
        done
    fi

    for system in "${systems[@]}"; do
        addEmulator 0 "${md_id}" "${system}" "${md_inst}/sameboy_libretro.so"
        addSystem "${system}"
    done
}
