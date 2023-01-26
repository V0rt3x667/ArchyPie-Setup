#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mgba"
rp_module_desc="Nintendo Game Boy, Game Boy Advance & Game Boy Color Libretro Core"
rp_module_help="ROM Extensions: .gb .gbc .gba .zip\n\nCopy your Game Boy roms to $romdir/gb\nGame Boy Color roms to $romdir/gbc\nGame Boy Advance roms to $romdir/gba\n\nCopy the recommended BIOS files gb_bios.bin, gbc_bios.bin, sgb_bios.bin and gba_bios.bin to $biosdir"
rp_module_licence="MPL2 https://raw.githubusercontent.com/libretro/mgba/master/LICENSE"
rp_module_repo="git https://github.com/libretro/mgba master"
rp_module_section="main"
rp_module_flags=""

function sources_lr-mgba() {
    gitPullOrClone
}

function build_lr-mgba() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/mgba_libretro.so"
}

function install_lr-mgba() {
    md_ret_files=(
        'mgba_libretro.so'
        'CHANGES'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-mgba() {
    local system
    local def
    for system in gb gbc gba; do
        def=0
        [[ "$system" == "gba" ]] && def=1
        mkRomDir "$system"
        defaultRAConfig "$system"
        addEmulator "$def" "$md_id" "$system" "$md_inst/mgba_libretro.so"
        addSystem "$system"
    done
}
