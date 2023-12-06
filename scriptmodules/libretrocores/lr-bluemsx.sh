#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-bluemsx"
rp_module_desc="Microsoft MSX, MSX2, Coleco ColecoVision, Sega SG-1000 & SpectraVideo Libretro Core"
rp_module_help="ROM Extensions: .7z .cas .col .dsk .m3u .mx1 .mx2 .ri .rom .sc .sg .zip\n\nCopy MSX Games To: ${romdir}/msx\n\nCopy MSX2 Games To: ${romdir}/msx2\n\nCopy ColecoVision Games To: ${romdir}/coleco\n\nCopy Sega SG-1000 Games To: ${romdir}/sg1000\n\nCopy SpectraVideo Games To: ${romdir}/spectravideo"
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
        'system/bluemsx/Databases'
        'system/bluemsx/Machines'
    )
}

function configure_lr-bluemsx() {
    local systems=(
        'coleco'
        'msx'
        'msx2'
        'sg-1000'
        'spectravideo'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            defaultRAConfig "${system}"
        done

        mkUserDir "${biosdir}/msx"

        # Copy Data To BIOS Directory
        cp -rv "${md_inst}/"{Databases,Machines} "${biosdir}/msx"
        chown -R "${user}:${user}" "${biosdir}/msx/"{Databases,Machines}

        # Symlink Supported Systems BIOS Dirs To 'Databases' & 'Machines' Folders
        for system in "${systems[@]}"; do
            if [[ "${system}" != "msx" ]]; then
                mkUserDir "${biosdir}/${system}"
                ln -sf "${biosdir}/msx/Databases" "${biosdir}/${system}/Databases"
                ln -sf "${biosdir}/msx/Machines" "${biosdir}/${system}/Machines"
            fi
        done

        # Force ColecoVision System
        local config="${md_conf_root}/coleco/retroarch-core-options.cfg"
        iniConfig " = " '"' "${config}"
        iniSet "bluemsx_msxtype" "ColecoVision"
        chown "${user}:${user}" "${config}"

        # Add ColecoVision Overide To 'retroarch.cfg', 'defaultRAConfig' Can Only Be Called Once
        local raconfig="${md_conf_root}/coleco/retroarch.cfg"
        iniConfig " = " '"' "${raconfig}"
        iniSet "core_options_path" "${config}"
        chown "${user}:${user}" "${raconfig}"

        # Force SpectraVideo System
        local config="${md_conf_root}/spectravideo/retroarch-core-options.cfg"
        iniConfig " = " '"' "${config}"
        iniSet "bluemsx_msxtype" "SVI - Spectravideo SVI-328 MK2"
        chown "${user}:${user}" "${config}"

        # Add SpectraVideo Overide To 'retroarch.cfg', 'defaultRAConfig' Can Only Be Called Once
        local raconfig="${md_conf_root}/spectravideo/retroarch.cfg"
        iniConfig " = " '"' "${raconfig}"
        iniSet "core_options_path" "${config}"
        chown "${user}:${user}" "${raconfig}"
    fi

    for system in "${systems[@]}"; do
        addEmulator 1 "${md_id}" "${system}" "${md_inst}/bluemsx_libretro.so"
        addSystem "${system}"
    done
}
