#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="snes9x-rpi"
rp_module_desc="SNES9X-RPi - Nintendo SNES Emulator"
rp_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/RetroPie/snes9x-rpi/master/snes9x.h"
rp_module_repo="git https://github.com/RetroPie/snes9x-rpi.git retropie"
rp_module_section="opt"
rp_module_flags="!all rpi"

function depends_snes9x-rpi() {
    getDepends sdl boost-libs sdl_ttf alsa-lib
}

function sources_snes9x-rpi() {
    gitPullOrClone
}

function build_snes9x-rpi() {
    make clean
    make
    md_ret_require="$md_build/snes9x"
}

function install_snes9x-rpi() {
    md_ret_files=(
        'changes.txt'
        'hardware.txt'
        'problems.txt'
        'readme.txt'
        'README.md'
        'snes9x'
    )
}

function configure_snes9x-rpi() {
    mkRomDir "snes"

    isPlatform "dispmanx" && setBackend "$md_id" "dispmanx"

    addEmulator 0 "$md_id" "snes" "$md_inst/snes9x %ROM%"
    addSystem "snes"
}
