#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ioquake3"
rp_module_desc="ioquake3 - Quake 3 Arena Port"
rp_module_licence="GPL2 https://github.com/ioquake/ioq3/blob/master/COPYING.txt"
rp_module_repo="git https://github.com/ioquake/ioq3.git main"
rp_module_section="opt"
rp_module_flags="!videocore"

function depends_ioquake3() {
    local depends=(
        'mesa'
        'perl-rename'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_ioquake3() {
    gitPullOrClone
}

function build_ioquake3() {
    make clean
    make COPYDIR="$md_inst" USE_INTERNAL_LIBS=0
    md_ret_require="$md_build/build/release-linux-$(_arch_ioquake3)/ioquake3.$(_arch_ioquake3)"
}

function _arch_ioquake3() {
    uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/'
}

function install_ioquake3() {
    make COPYDIR="$md_inst" USE_INTERNAL_LIBS=0 copyfiles
}

function _add_games_ioquake3() {
    local cmd="$1"
    local dir
    local game
    declare -A games=(
        ['baseq3/pak0.pk3']="Quake III Arena"
        ['missionpack/pak0.pk3']="Quake III: Team Arena"
    )

    for game in "${!games[@]}"; do
        dir="$romdir/ports/quake3/$game"
        # Convert Uppercase Filenames to Lowercase
        pushd "${dir%/*}"
        perl-rename 'y/A-Z/a-z/' [^.-]*
        popd
        if [[ -f "$dir" ]]; then
            if [[ "$game" == "missionpack/pak0.pk3" ]]; then
                addPort "$md_id" "quake3" "${games[$game]}" "$cmd" "${game%/*}"
            else
                addPort "$md_id" "quake3" "${games[$game]}" "$cmd" "${game%/*}"
            fi
        fi
    done
}

function configure_ioquake3() {
    mkRomDir "ports/quake3"

    moveConfigDir "$md_inst/baseq3" "$romdir/ports/quake3/baseq3"
    moveConfigDir "$md_inst/missionpack" "$romdir/ports/quake3/missionpack"
    moveConfigDir "$home/.q3a" "$md_conf_root/ioquake3"

    [[ "$md_mode" == "install" ]] && _game_data_quake3
    
    local launcher=("$md_inst/ioquake3.$(_arch_ioquake3) +set fs_game %ROM%")
    isPlatform "mesa" && launcher+=("+set cl_renderer opengl1")
    isPlatform "kms" && launcher+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%" "+set r_swapInterval 1")
    isPlatform "x11" && launcher+=("+set r_mode -2" "+set r_fullscreen 1")

    _add_games_ioquake3 "${launcher[*]}"
}
