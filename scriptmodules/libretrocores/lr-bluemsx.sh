#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-bluemsx"
rp_module_desc="Microsoft MSX, MSX2, Coleco ColecoVision & Sega SG-1000 Libretro Core"
rp_module_help="ROM Extensions: .cas .col .dsk .m3u .mx1 .mx2 .ri .rom .sc .sg\n\nCopy MSX Games To: ${romdir}/msx\nCopy MSX2 Games To: ${romdir}/msx2\nCopy Colecovision Games To: ${romdir}/coleco"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/blueMSX-libretro/master/license.txt"
rp_module_repo="git https://github.com/libretro/blueMSX-libretro master"
rp_module_section="opt"

function sources_lr-bluemsx() {
    gitPullOrClone
}

function build_lr-bluemsx() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro

    md_ret_require="${md_build}/bluemsx_libretro.so"
}

function install_lr-bluemsx() {
    md_ret_files=(
        'bluemsx_libretro.so'
        'README.md'
        'system/bluemsx/Databases'
        'system/bluemsx/Machines'
    )
}

function configure_lr-bluemsx() {
    local systems=(
        'coleco'
        'msx'
        'msx2'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            mkUserDir "${biosdir}/msx"
        done

        # Copy Data To BIOS Directory
        cp -rv "${md_inst}/"{Databases,Machines} "${biosdir}/msx"
        chown -R "${user}:${user}" "${biosdir}/msx/"{Databases,Machines}

        # Force ColecoVision System
        local config="${md_conf_root}/coleco/retroarch-core-options.cfg"
        iniConfig " = " '"' "${config}"
        iniSet "bluemsx_msxtype" "ColecoVision" "${config}"
        chown "${user}:${user}" "${config}"
    fi

    for system in "${systems[@]}"; do
        defaultRAConfig "${system}" "system_directory" "${biosdir}/msx" 
        addEmulator 1 "${md_id}" "${system}" "${md_inst}/bluemsx_libretro.so"
        addSystem "${system}"
    done

    # Add ColecoVision Overide To 'retroarch.cfg', 'defaultRAConfig' Can Only Be Called Once
    local raconfig="${md_conf_root}/coleco/retroarch.cfg"
    iniConfig " = " '"' "${raconfig}"
    iniSet "core_options_path" "${config}"
    chown "${user}:${user}" "${raconfig}"
}
