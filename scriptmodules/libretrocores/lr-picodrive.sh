#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-picodrive"
rp_module_desc="Sega Master System, Mega Drive (Genesis), Sega CD & Sega 32X Libretro Core"
rp_module_help="ROM Extensions: .32x .iso .cue .sms .smd .bin .gen .md .sg .zip\n\nCopy your Megadrive / Genesis roms to $romdir/megadrive\nMasterSystem roms to $romdir/mastersystem\nSega 32X roms to $romdir/sega32x and\nSegaCD roms to $romdir/segacd\nThe Sega CD requires the BIOS files us_scd1_9210.bin, eu_mcd1_9210.bin, jp_mcd1_9112.bin copied to $biosdir"
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
    make clean
    make -f Makefile.libretro "${params[@]}"
    md_ret_require="$md_build/picodrive_libretro.so"
}

function install_lr-picodrive() {
    md_ret_files=(
        'AUTHORS'
        'COPYING'
        'picodrive_libretro.so'
        'README'
    )
}

function configure_lr-picodrive() {
    local system
    local def
    for system in megadrive mastersystem segacd sega32x; do
        def=0
        mkRomDir "$system"
        defaultRAConfig "$system"
        addEmulator $def "$md_id" "$system" "$md_inst/picodrive_libretro.so"
        addSystem "$system"
    done
}
