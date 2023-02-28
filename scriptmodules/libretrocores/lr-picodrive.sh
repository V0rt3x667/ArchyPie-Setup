#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-picodrive"
rp_module_desc="Sega Master System, Mega Drive (Genesis), Sega CD & Sega 32X Libretro Core"
rp_module_help="ROM Extensions: .32x .68k .bin .chd .cue .gen .gg .iso .m3u .md .pco .sgd .smd .sms .zip\n\nCopy Megadrive (Genesis) ROMs To: ${romdir}/megadrive\nCopy MasterSystem ROMs To: ${romdir}/mastersystem\nCopy Sega 32X ROMs To: ${romdir}/sega32x\nCopy SegaCD ROMs To: ${romdir}/segacd\n\nCopy BIOS Files (bios_CD_E.bin, bios_CD_J.bin & bios_CD_U.bin) To: ${biosdir}/segacd"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/picodrive/master/COPYING"
rp_module_repo="git https://github.com/libretro/picodrive master"
rp_module_section="main"

function sources_lr-picodrive() {
    gitPullOrClone
}

function build_lr-picodrive() {
    local params=()
    if isPlatform "arm"; then
        params+=(platform=armv ARM_ASM=1 use_fame=0 use_cyclone=1 use_sh2drc=1 use_svpdrc=1 use_cz80=1 use_drz80=0)
    elif isPlatform "aarch64"; then
        params+=(use_sh2drc=0)
    fi
    make -f Makefile.libretro clean
    make -f Makefile.libretro "${params[@]}"
    md_ret_require="${md_build}/picodrive_libretro.so"
}

function install_lr-picodrive() {
    md_ret_files=(
        'COPYING'
        'picodrive_libretro.so'
    )
}

function configure_lr-picodrive() {
    local systems=(
        'mastersystem'
        'megadrive'
        'sega32x'
        'segacd'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
        done

        mkUserDir "${biosdir}/segacd"
    fi

    defaultRAConfig "mastersystem"
    defaultRAConfig "megadrive"
    defaultRAConfig "sega32x"
    defaultRAConfig "segacd" "system_directory" "${biosdir}/segacd"

    for system in "${systems[@]}"; do
        addEmulator 0 "${md_id}" "${system}" "${md_inst}/picodrive_libretro.so"
        addSystem "${system}"
    done
}
