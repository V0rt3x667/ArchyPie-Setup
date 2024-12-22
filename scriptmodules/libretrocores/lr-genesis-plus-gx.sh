#!/bin/bash

################################################################################
# This file is part of the ArchyPie Project                                    #
#                                                                              #
# Please see the LICENSE file at the top-level directory of this distribution. #
################################################################################

rp_module_id="lr-genesis-plus-gx"
rp_module_desc="Sega Master System, Game Gear, Mega Drive (Genesis), Sega CD, SG-1000 & Sega Pico Libretro Core"
rp_module_help="ROM Extensions: .68k .bin .bms .chd .cue .gen .gg .iso .m3u .md .mdx .sg .sgd .smd .sms .zip\n\nCopy Game Gear ROMs to: ${romdir}/gamegear\n\nCopy MasterSystem ROMs to: ${romdir}/mastersystem\n\nCopy Megadrive (Genesis) ROMs to: ${romdir}/megadrive\n\nCopy SG-1000 ROMs to: ${romdir}/sg-1000\n\nCopy Sega Pico ROMs to: ${romdir}/pico\n\nCopy SegaCD ROMs to: ${romdir}/segacd\n\nCopy Sega CD BIOS files: bios_CD_U.bin, bios_CD_E.bin & bios_CD_J.bin to: ${biosdir}/segacd\n\nOPTIONAL: Copy BIOS files: bios_MD.bin, bios_E.sms, bios_U.sms, bios_J.sms, bios.gg, sk.bin, sk2chip.bin, areplay.bin & ggenie.bin to the relevant BIOS directories"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/Genesis-Plus-GX/master/LICENSE.txt"
rp_module_repo="git https://github.com/libretro/Genesis-Plus-GX master"
rp_module_section="main"
rp_module_flags="all"

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
    # Install licence
    install -D644 LICENSE.txt -t "${md_inst}/LICENCE"
}

function configure_lr-genesis-plus-gx() {
    local systems=(
        'gamegear'
        'mastersystem'
        'megadrive'
        'pico'
        'segacd'
        'sg-1000'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            mkUserDir "${biosdir}/${system}"
            defaultRAConfig  "${system}"
        done
    fi

    for system in "${systems[@]}"; do
        addEmulator 1 "${md_id}" "${system}" "${md_inst}/genesis_plus_gx_libretro.so"
        addSystem "${system}"
    done
}
