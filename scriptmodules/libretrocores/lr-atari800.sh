#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-atari800"
rp_module_desc="Atari 5200, 400, 800, XL & XE Libretro Core"
rp_module_help="ROM Extensions: .a52 .bas .bin .car .xex .atr .xfd .dcm .atr.gz .xfd.gz\n\nCopy your Atari800 games to $romdir/atari800\n\nCopy your Atari 5200 roms to $romdir/atari5200 You need to copy the Atari 800/5200 BIOS files (5200.ROM, ATARIBAS.ROM, ATARIOSB.ROM and ATARIXL.ROM) to the folder $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-atari800/master/atari800/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-atari800 master"
rp_module_section="main"

function sources_lr-atari800() {
    gitPullOrClone
}

function build_lr-atari800() {
    make clean
    CFLAGS+=" -DDEFAULT_CFG_NAME=\\\".lr-atari800.cfg\\\"" make
    md_ret_require="$md_build/atari800_libretro.so"
}

function install_lr-atari800() {
    md_ret_files=(
        'atari800_libretro.so'
        'atari800/COPYING'
    )
}

function configure_lr-atari800() {
    mkRomDir "atari800"
    mkRomDir "atari5200"

    defaultRAConfig "atari800"
    defaultRAConfig "atari5200"

    mkUserDir "$md_conf_root/atari800"
    moveConfigFile "$home/.lr-atari800.cfg" "$md_conf_root/atari800/lr-atari800.cfg"

    addEmulator 1 "lr-atari800" "atari800" "$md_inst/atari800_libretro.so"
    addEmulator 1 "lr-atari800" "atari5200" "$md_inst/atari800_libretro.so"
    addSystem "atari800"
    addSystem "atari5200"
}
