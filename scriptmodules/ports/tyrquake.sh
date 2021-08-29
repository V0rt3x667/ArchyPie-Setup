#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="tyrquake"
rp_module_desc="TyrQuake - Quake Port"
rp_module_licence="GPL2 https://disenchant.net/git/tyrquake.git/plain/gnu.txt?h=v0.68&id=2505bd88a4559d0b640fdc1524f776c73fc56c05"
rp_module_repo="file https://disenchant.net/files/engine/tyrquake-0.68.tar.gz"
rp_module_section="opt"

function depends_tyrquake() {
    local depends=(sdl2)
    if isPlatform "gl" || isPlatform "mesa"; then
        depends+=(libglvnd)
    fi

    getDepends "${depends[@]}"
}

function sources_tyrquake() {
    downloadAndExtract "$md_repo_url" "$md_build" --strip-components 1
    isPlatform "kms" && applyPatch "$md_data/01_force_vsync.patch"
}

function build_tyrquake() {
    local params=(USE_SDL=Y USE_XF86DGA=N LOCALBASE="$md_inst")
    make clean
    make "${params[@]}"
    md_ret_require="$md_build/bin/tyr-quake"
}

function install_tyrquake() {
    md_ret_files=(
        'changelog.txt'
        'readme.txt'
        'readme-id.txt'
        'gnu.txt'
        'bin'
    )
}

function add_games_tyrquake() {
    local params=("-basedir $romdir/ports/quake" "-game %QUAKEDIR%")
    local binary="$md_inst/bin/tyr-quake"

    isPlatform "kms" && params+=("-width %XRES%" "-height %YRES%")
    if isPlatform "gl" || isPlatform "mesa"; then
        binary="$md_inst/bin/tyr-glquake"
    fi

    _add_games_lr-tyrquake "$binary ${params[*]}"
}

function configure_tyrquake() {
    mkRomDir "ports/quake"

    [[ "$md_mode" == "install" ]] && game_data_lr-tyrquake

    add_games_tyrquake

    moveConfigDir "$home/.tyrquake" "$md_conf_root/quake/tyrquake"
}
