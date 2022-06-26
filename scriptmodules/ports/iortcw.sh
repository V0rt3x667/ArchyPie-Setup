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

function configure_iortcw() {
    local launcher
    isPlatform "mesa" && launcher+=("+set cl_renderer opengl1")
    isPlatform "kms" && launcher+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%" "+set r_swapInterval 1")
    isPlatform "x11" && launcher+=("+set r_mode -2" "+set r_fullscreen 1")

    addPort "$md_id" "rtcw" "Return to Castle Wolfenstein (SP)" "$md_inst/iowolfsp.$(_arch_iortcw) ${launcher[*]}"
    addPort "$md_id" "rtcw-mp" "Return to Castle Wolfenstein (MP)" "$md_inst/iowolfmp.$(_arch_iortcw) ${launcher[*]}"

    mkRomDir "ports/rtcw"

    moveConfigDir "$home/.wolf" "$md_conf_root/iortcw"
    moveConfigDir "$md_inst/main" "$romdir/ports/rtcw/main"
    chown -R "$user:$user" "$romdir/ports/rtcw"
}
