#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-cannonball"
rp_module_desc="Cannonball (Enhanced OutRun Engine) Libretro Core"
rp_module_help="Unzip OutRun Set B From MAME (outrun.zip) To: ${romdir}/ports/cannonball\n\nRename File 'epr-10381a.132' To 'epr-10381b.132'"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/cannonball/master/docs/license.txt"
rp_module_repo="git https://github.com/libretro/cannonball master"
rp_module_section="opt"

function sources_lr-cannonball() {
    gitPullOrClone
}

function build_lr-cannonball() {
    make clean
    make
    md_ret_require="${md_build}/cannonball_libretro.so"
}

function install_lr-cannonball() {
    md_ret_files=(
        'cannonball_libretro.so'
        'docs/license.txt'
        'res'
        'roms/roms.txt'
    )
}

function configure_lr-cannonball() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ports/cannonball"
        setConfigRoot "ports"
        defaultRAConfig "cannonball"

        # Symlink Directories
        ln -snf "${romdir}/ports/cannonball" "${md_inst}/roms"
        ln -snf "${md_inst}/res/" "${romdir}/ports/cannonball/res"

        cp -v roms.txt "${romdir}/ports/cannonball/"
        chown -R "${__user}":"${__group}" "${romdir}/ports/cannonball"
    fi

    addPort "${md_id}" "cannonball" "Cannonball: OutRun Engine" "${md_inst}/cannonball_libretro.so ${romdir}/ports/cannonball/"
}
