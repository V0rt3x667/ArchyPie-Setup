#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="pisnes"
rp_module_desc="PiSNES - Nintendo SNES Emulator"
rp_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/RetroPie/pisnes/master/snes9x.h"
rp_module_repo="git https://github.com/RetroPie/pisnes.git master"
rp_module_section="opt"
rp_module_flags="!all rpi"

function depends_pisnes() {
    getDepends ffmpeg sdl raspberrypi-firmware libjpeg
}

function sources_pisnes() {
    gitPullOrClone
}

function build_pisnes() {
    make clean
    make
    md_ret_require="$md_build/snes9x"
}

function install_pisnes() {
    md_ret_files=(
        'changes.txt'
        'hardware.txt'
        'problems.txt'
        'readme_snes9x.txt'
        'readme.txt'
        'roms'
        'skins'
        'snes9x'
        'snes9x.cfg.template'
        'snes9x.gui'
    )
}

function configure_pisnes() {
    mkRomDir "snes"

    addEmulator 0 "$md_id" "snes" "$md_inst/snes9x %ROM%"
    addSystem "snes"

    [[ "$md_mode" == "remove" ]] && return

    moveConfigFile "$md_inst/snes9x.cfg" "$md_conf_root/snes/snes9x.cfg"
    copyDefaultConfig "$md_inst/snes9x.cfg.template" "$md_conf_root/snes/snes9x.cfg"
}
