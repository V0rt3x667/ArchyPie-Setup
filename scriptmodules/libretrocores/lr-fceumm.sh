#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-fceumm"
rp_module_desc="Nintendo NES & Famicom Libretro Core"
rp_module_help="ROM Extensions: .nes .zip\n\nCopy your NES roms to $romdir/nes\n\nFor the Famicom Disk System copy your roms to $romdir/fds\n\nFor the Famicom Disk System copy the required BIOS file disksys.rom to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-fceumm/master/Copying"
rp_module_repo="git https://github.com/libretro/libretro-fceumm master"
rp_module_section="main"

function sources_lr-fceumm() {
    gitPullOrClone
}

function build_lr-fceumm() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/fceumm_libretro.so"
}

function install_lr-fceumm() {
    md_ret_files=(
        'Authors'
        'changelog.txt'
        'Copying'
        'fceumm_libretro.so'
        'whatsnew.txt'
        'zzz_todo.txt'
    )
}

function configure_lr-fceumm() {
    mkRomDir "nes"
    mkRomDir "fds"
    defaultRAConfig "nes"
    defaultRAConfig "fds"

    addEmulator 1 "$md_id" "nes" "$md_inst/fceumm_libretro.so"
    addEmulator 0 "$md_id" "fds" "$md_inst/fceumm_libretro.so"
    addSystem "nes"
    addSystem "fds"
}
