#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-kronos"
rp_module_desc="Saturn & ST-V Libretro Core"
rp_module_help="ROM Extensions: .ccd .chd .cue .iso .m3u .mds .zip\n\nCopy Sega Saturn & ST-V ROMs To: ${romdir}/saturn\n\nCopy BIOS Files (saturn_bios.bin & stvbios.zip) To: ${biosdir}/saturn"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/yabause/kronos/yabause/COPYING"
rp_module_repo="git https://github.com/libretro/yabause kronos"
rp_module_section="exp"
rp_module_flags="!aarch64 !arm"

function sources_lr-kronos() {
    gitPullOrClone

    # Set BIOS Directory
    sed -e "s|sizeof(stv_bios_path), \"%s%ckronos|sizeof(stv_bios_path), \"%s%csaturn|g" -i "${md_build}/yabause/src/libretro/libretro.c"
    sed -e "s|sizeof(bios_path), \"%s%ckronos|sizeof(bios_path), \"%s%csaturn|g" -i "${md_build}/yabause/src/libretro/libretro.c"
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
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "saturn"

        mkUserDir "${biosdir}/saturn"
    fi

    defaultRAConfig "saturn"

    addEmulator 1 "${md_id}" "saturn" "${md_inst}/kronos_libretro.so"

    addSystem "saturn"
}
