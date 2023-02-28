#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-genesis-plus-gx"
rp_module_desc="Sega Master System, Game Gear, Mega Drive (Genesis), Sega CD & SG-1000 Libretro Core"
rp_module_help="ROM Extensions: .68k .bin .bms .chd .cue .gen .gg .iso .m3u .md .mdx .sg .sgd .smd .sms .zip\nCopy Game Gear ROMs To: ${romdir}/gamegear\nCopy MasterSystem ROMs To: ${romdir}/mastersystem\nCopy Megadrive (Genesis) ROMs To: ${romdir}/megadrive\nCopy SG-1000 ROMs To: ${romdir}/sg-1000\nCopy SegaCD ROMs To: ${romdir}/segacd\nCopy Sega CD BIOS Files (bios_CD_U.bin, bios_CD_E.bin & bios_CD_J.bin) To: ${biosdir}/segacd"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/Genesis-Plus-GX/master/LICENSE.txt"
rp_module_repo="git https://github.com/libretro/Genesis-Plus-GX master"
rp_module_section="main"

function sources_lr-genesis-plus-gx() {
    gitPullOrClone
}

function build_lr-genesis-plus-gx() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="${md_build}/genesis_plus_gx_libretro.so"
}

function install_lr-genesis-plus-gx() {
    md_ret_files=('genesis_plus_gx_libretro.so')
}

function configure_lr-genesis-plus-gx() {
    local systems=(
        'gamegear'
        'mastersystem'
        'megadrive'
        'segacd'
        'sg-1000'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
        done

        mkUserDir "${biosdir}/segacd"
    fi

    defaultRAConfig "gamegear"
    defaultRAConfig "mastersystem"
    defaultRAConfig "megadrive"
    defaultRAConfig "segacd" "system_directory" "${biosdir}/segacd"
    defaultRAConfig "sg-1000"

    for system in "${systems[@]}"; do
        addEmulator 1 "${md_id}" "${system}" "${md_inst}/genesis_plus_gx_libretro.so"
        addSystem "${system}"
    done
}
