#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="iortcw"
rp_module_desc="iortcw - Return to Castle Wolfenstein Port"
rp_module_licence="GPL3 https://raw.githubusercontent.com/iortcw/iortcw/master/LICENCE.md"
rp_module_repo="git https://github.com/iortcw/iortcw.git master"
rp_module_section="opt"
rp_module_flags=""

function depends_iortcw() {
    local depends=(
        'freetype2'
        'graphite'
        'harfbuzz'
        'libjpeg-turbo'
        'libogg'
        'openal'
        'opus'
        'opusfile'
        'perl-rename'
        'pcre'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_iortcw() {
    gitPullOrClone
}

function build_iortcw() {
    local dirs=('MP' 'SP')
    for dir in "${dirs[@]}"; do
        make -C "$dir" clean
        make -C "$dir" COPYDIR="$md_inst" USE_INTERNAL_LIBS=0
    done
    md_ret_require=(
        "$md_build/MP/build/release-linux-$(_arch_iortcw)/iowolfmp.$(_arch_iortcw)"
        "$md_build/SP/build/release-linux-$(_arch_iortcw)/iowolfsp.$(_arch_iortcw)"
    )
}

function _arch_iortcw() {
    uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/'
}

function install_iortcw() {
    local dirs=('MP' 'SP')
    for dir in "${dirs[@]}"; do
        make -C "$dir" COPYDIR="$md_inst" USE_INTERNAL_LIBS=0 copyfiles
    done
}

function _add_games_iortcw() {
    local cmd="$1"
    local dir
    local game
    declare -A games=(
        ['main/pak0.pk3']="Return to Castle Wolfenstein (SP)"
        ['main/mp_pak0.pk3']="Return to Castle Wolfenstein (MP)"
    )

    for game in "${!games[@]}"; do
        dir="$romdir/ports/rtcw/$game"
        # Convert Uppercase Filenames to Lowercase
        pushd "${dir%/*}"
        perl-rename 'y/A-Z/a-z/' *
        popd
        if [[ -f "$dir" ]]; then
            if [[ "$game" == "main/mp_pak0.pk3" ]]; then
                addPort "$md_id" "rtcw" "${games[$game]}" "$cmd" "iowolfmp"
            else
                addPort "$md_id" "rtcw" "${games[$game]}" "$cmd" "iowolfsp"
            fi
        fi
    done
}

function configure_iortcw() {
    mkRomDir "ports/rtcw"

    moveConfigDir "$md_inst/main" "$romdir/ports/rtcw/main"
    moveConfigDir "$home/.wolf" "$md_conf_root/iortcw"
    #chown -R "$user:$user" "$romdir/ports/rtcw"

    [[ "$md_mode" == "remove" ]] && return 

    local launcher=("$md_inst/%ROM%.$(_arch_iortcw)")
    isPlatform "mesa" && launcher+=("+set cl_renderer opengl1")
    isPlatform "kms" && launcher+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%" "+set r_swapInterval 1")
    isPlatform "x11" && launcher+=("+set r_mode -2" "+set r_fullscreen 1")

    _add_games_iortcw "${launcher[*]}"
}
