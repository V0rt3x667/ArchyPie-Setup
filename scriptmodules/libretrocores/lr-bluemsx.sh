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
            mkUserDir "${biosdir}/${system}"

            # Symlink Supported Systems BIOS Directories To 'Databases' & 'Machines' Folders
            if [[ "${system}" != "msx" ]]; then
                ln -sf "${biosdir}/msx/Databases" "${biosdir}/${system}/Databases"
                ln -sf "${biosdir}/msx/Machines" "${biosdir}/${system}/Machines"
            fi

            # Force ColecoVision & SpectraVideo Systems
            local config="${md_conf_root}/${system}/retroarch-core-options.cfg"
            if [[ "${system}" == "coleco" ]] || [[ "${system}" == "spectravideo" ]]; then
                defaultRAConfig  "${system}" "core_options_path" "${config}"
                iniConfig " = " '"' "${config}"
                if [[ "${system}" == "coleco" ]]; then
                    iniSet "bluemsx_msxtype" "ColecoVision" "${config}"
                elif [[ "${system}" == "spectravideo" ]]; then
                    iniSet "bluemsx_msxtype" "SVI - Spectravideo SVI-328 MK2" "${config}"
                fi
                chown "${user}:${user}" "${config}"
            else
                defaultRAConfig "${system}"
            fi
        done

        # Copy Data To 'msx' BIOS Directory
        cp -r "${md_inst}/"{Databases,Machines} "${biosdir}/msx"
        chown -R "${user}:${user}" "${biosdir}/msx"
    fi

    for system in "${systems[@]}"; do
        addEmulator 1 "${md_id}" "${system}" "${md_inst}/bluemsx_libretro.so"
        addSystem "${system}"
    done
}
