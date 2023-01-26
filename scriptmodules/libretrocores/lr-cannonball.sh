#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-cannonball"
rp_module_desc="Cannonball (Enhanced OutRun Engine) Libretro Core"
rp_module_help="You need to unzip your OutRun set B from MAME (outrun.zip) to $romdir/ports/cannonball. They should match the file names listed in the roms.txt file found in the roms folder. You will also need to rename the epr-10381a.132 file to epr-10381b.132 before it will work."
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/cannonball/master/docs/license.txt"
rp_module_repo="git https://github.com/libretro/cannonball master"
rp_module_section="opt"

function sources_lr-cannonball() {
    gitPullOrClone
}

function build_lr-cannonball() {
    make clean
    make
    md_ret_require="$md_build/cannonball_libretro.so"
}

function install_lr-cannonball() {
    md_ret_files=(
        'cannonball_libretro.so'
        'roms/roms.txt'
        'docs/license.txt'
    )

    mkdir -p "$md_inst/res"
    cp -v res/*.bin "$md_inst/res/"
    cp -v res/config_sdl2.xml "$md_inst/config.xml.def"
}

function configure_lr-cannonball() {
    mkRomDir "ports/cannonball"
    setConfigRoot "ports"
    defaultRAConfig "cannonball"

    addPort "$md_id" "cannonball" "Cannonball: OutRun Engine" "$md_inst/cannonball_libretro.so" "$romdir/ports/cannonball/outrun.game"

    moveConfigFile "config.xml" "$md_conf_root/cannonball/config.xml"
    moveConfigFile "hiscores.xml" "$md_conf_root/cannonball/hiscores.xml"

    [[ "$md_mode" == "remove" ]] && return

    copyDefaultConfig "$md_inst/config.xml.def" "$md_conf_root/cannonball/config.xml"

    cp -v roms.txt "$romdir/ports/cannonball/"

    chown -R "${user}:${user}" "$romdir/ports/cannonball" "$md_conf_root/cannonball"

    ln -snf "$romdir/ports/cannonball" "$md_inst/roms"
}
