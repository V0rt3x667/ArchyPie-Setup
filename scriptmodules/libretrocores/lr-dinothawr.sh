#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-dinothawr"
rp_module_desc="Dinothawr Libretro Core"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/Dinothawr/master/LICENSE"
rp_module_repo="git https://github.com/libretro/Dinothawr master"
rp_module_section="opt"

function sources_lr-dinothawr() {
    gitPullOrClone
}

function build_lr-dinothawr() {
    make clean
    make
    md_ret_require="${md_build}/dinothawr_libretro.so"
}

function install_lr-dinothawr() {
    md_ret_files=(
        'dinothawr_libretro.so'
        'dinothawr'
    )
}

function configure_lr-dinothawr() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ports/dinothawr"
        setConfigRoot "ports"
        defaultRAConfig "dinothawr"

        cp -Rv "${md_inst}"/dinothawr/* "${romdir}/ports/dinothawr/"
        chown "${user}:${user}" -R "${romdir}/ports/dinothawr"
    fi

    addPort "${md_id}" "dinothawr" "Dinothawr" "${md_inst}/dinothawr_libretro.so" "${romdir}/ports/dinothawr/dinothawr.game"
}
