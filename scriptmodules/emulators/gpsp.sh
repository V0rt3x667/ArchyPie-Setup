#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="gpsp"
rp_module_desc="GPSP - Nintendo GameBoy Advance Emulator"
rp_module_help="ROM Extensions: .gba .zip\n\nCopy your Game Boy Advance roms to $romdir/gba\n\nCopy the required BIOS file gba_bios.bin to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/gizmo98/gpsp/master/COPYING.DOC"
rp_module_repo="git https://github.com/gizmo98/gpsp.git master"
rp_module_section="opt"
rp_module_flags="noinstclean !all rpi"

function depends_gpsp() {
    getDepends sdl raspberrypi-firmware #gcc-6
}

function sources_gpsp() {
    gitPullOrClone
}

function build_gpsp() {
    cd raspberrypi
    rpSwap on 512
    make clean
    make #CC="gcc-6"
    rpSwap off
    md_ret_require="$md_build/raspberrypi/gpsp"
}

function install_gpsp() {
    md_ret_files=(
        'COPYING.DOC'
        'game_config.txt'
        'readme.txt'
        'raspberrypi/gpsp'
    )
}

function configure_gpsp() {
    mkRomDir "gba"
    chown "${user}:${user}" -R "$md_inst"

    mkUserDir "$md_conf_root/gba"

    # symlink the rom so so it can be installed with the other bios files
    ln -sf "$biosdir/gba_bios.bin" "$md_inst/gba_bios.bin"

    # move old config
    moveConfigFile "gpsp.cfg" "$md_conf_root/gba/gpsp.cfg"

    addEmulator 0 "$md_id" "gba" "$md_inst/gpsp %ROM%"
    addSystem "gba"
}
