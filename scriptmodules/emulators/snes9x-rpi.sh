#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="snes9x-rpi"
rp_module_desc="SNES9X-RPi: Nintendo SNES Emulator"
rp_module_help="ROM Extensions: .bin .fig .mgd .sfc .smc .swc .zip\n\nCopy SNES ROMs To: ${romdir}/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/RetroPie/snes9x-rpi/master/snes9x.h"
rp_module_repo="git https://github.com/RetroPie/snes9x-rpi retropie"
rp_module_section="opt"
rp_module_flags="!all rpi"

function depends_snes9x-rpi() {
    local depends=(
        'ffmpeg'
        'libjpeg-turbo'
        'raspberrypi-firmware'
        'sdl12-compat'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_snes9x-rpi() {
    gitPullOrClone
}

function build_snes9x-rpi() {
    make clean
    make
    md_ret_require="${md_build}/${md_id}"
}

function install_snes9x-rpi() {
    md_ret_files=(
        'changes.txt'
        'hardware.txt'
        'problems.txt'
        'README.md'
        'readme.txt'
        'snes9x'
    )
}

function configure_snes9x-rpi() {
    mkRomDir "snes"

    addEmulator 0 "${md_id}" "snes" "${md_inst}/${md_id} %ROM%"

    addSystem "snes"
}
