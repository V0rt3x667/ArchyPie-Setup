#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-kronos"
rp_module_desc="Sega Saturn & Sega Titan Video (ST-V) Libretro Core"
rp_module_help="ROM Extensions: .ccd .chd .cue .iso .m3u .mds .zip\n\nCopy Sega Saturn ROMs To: ${romdir}/saturn\n\nCopy Sega ST-V ROMs To: ${romdir}/segastv\n\nCopy BIOS Files: saturn_bios.bin & stvbios.zip To: ${biosdir}/saturn"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/yabause/kronos/yabause/COPYING"
rp_module_repo="git https://github.com/libretro/yabause kronos"
rp_module_section="exp"
rp_module_flags="!aarch64 !arm"

function sources_lr-kronos() {
    gitPullOrClone
}

function build_lr-kronos() {
    make -C yabause/src/libretro clean
    make -C yabause/src/libretro
    md_ret_require="${md_build}/yabause/src/libretro/kronos_libretro.so"
}

function install_lr-kronos() {
    md_ret_files=('yabause/src/libretro/kronos_libretro.so')
}

function configure_lr-kronos() {
    local systems=(
        'arcade'
        'saturn'
        'segastv'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            mkUserDir "${biosdir}/${system}"
            defaultRAConfig "${system}"

            # Symlink Supported Systems BIOS Dirs To 'saturn'
            if [[ "${system}" != "saturn" ]]; then
                ln -snf "${biosdir}/saturn" "${biosdir}/${system}/kronos"
            fi
        done
    fi

    for system in "${systems[@]}"; do
        local def=1
        if [[ "${system}" == "arcade" ]]; then
            def=0
        fi
        addEmulator "${def}" "${md_id}" "${system}" "${md_inst}/kronos_libretro.so"
        addSystem "${system}"
    done
}
