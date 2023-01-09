#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-dinothawr"
rp_module_desc="Dinothawr Libretro Core"
rp_module_help="Dinothawr game assets are automatically installed to $romdir/ports/dinothawr/"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/Dinothawr/master/LICENSE"
rp_module_repo="git https://github.com/libretro/Dinothawr.git master"
rp_module_section="exp"

function sources_lr-dinothawr() {
    gitPullOrClone
}

function build_lr-dinothawr() {
    make clean
    # libretro-common has an issue with neon
    if isPlatform "neon"; then
        CFLAGS="" make
    else
        make
    fi
    md_ret_require="$md_build/dinothawr_libretro.so"
}

function install_lr-dinothawr() {
    md_ret_files=(
        'dinothawr_libretro.so'
        'dinothawr'
    )
}


function configure_lr-dinothawr() {
    setConfigRoot "ports"

    addPort "$md_id" "dinothawr" "Dinothawr" "$md_inst/dinothawr_libretro.so" "$romdir/ports/dinothawr/dinothawr.game"

    mkRomDir "ports/dinothawr"
    defaultRAConfig "dinothawr"

    cp -Rv "$md_inst/dinothawr" "$romdir/ports"

    chown "${user}:${user}" -R "$romdir/ports/dinothawr"
}
