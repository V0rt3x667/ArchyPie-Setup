#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="pisnes"
rp_module_desc="PiSNES: Nintendo SNES Emulator"
rp_module_help="ROM Extensions: .bin .fig .mgd .sfc .smc .swc .zip\n\nCopy SNES ROMs To: ${romdir}/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/RetroPie/pisnes/master/snes9x.h"
rp_module_repo="git https://github.com/RetroPie/pisnes master"
rp_module_section="opt"
rp_module_flags="!all rpi"

function depends_pisnes() {
    local depends=(
        'ffmpeg'
        'libjpeg-turbo'
        'raspberrypi-firmware'
        'sdl12-compat'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_pisnes() {
    gitPullOrClone
}

function build_pisnes() {
    make clean
    make
    md_ret_require="${md_build}/snes9x"
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
        'snes9x.cfg.template'
        'snes9x.gui'
        'snes9x'
    )
}

function configure_pisnes() {
    moveConfigFile "${md_inst}/snes9x.cfg" "${md_conf_root}/snes/snes9x.cfg"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "snes"
        copyDefaultConfig "${md_inst}/snes9x.cfg.template" "${md_conf_root}/snes/snes9x.cfg"
    fi

    addEmulator 0 "${md_id}" "snes" "${md_inst}/snes9x %ROM%"

    addSystem "snes"
}
