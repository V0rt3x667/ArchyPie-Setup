#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mupen64plus"
rp_module_desc="Nintendo N64 Libretro Core"
rp_module_help="ROM Extensions: .z64 .n64 .v64\n\nCopy your N64 roms to $romdir/n64"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mupen64plus-libretro/master/LICENSE"
rp_module_repo="git https://github.com/RetroPie/mupen64plus-libretro master"
rp_module_section="main"
rp_module_flags="!aarch64"

function depends_lr-mupen64plus() {
    local depends=(flex bison libpng)
    isPlatform "x11" && depends+=(glew mesa)
    isPlatform "x86" && depends+=(nasm)
    isPlatform "mesa" && depends+=(libglvnd)
    isPlatform "rpi" && depends+=(raspberrypi-firmware)
    getDepends "${depends[@]}"
}

function sources_lr-mupen64plus() {
    gitPullOrClone
}

function build_lr-mupen64plus() {
    rpSwap on 750
    local params=()
    if isPlatform "rpi"; then
        params+=(platform="$__platform")
    elif isPlatform "mesa"; then
        params+=(platform="$__platform-mesa")
    elif isPlatform "mali"; then
        params+=(platform="odroid")
    else
        isPlatform "arm" && params+=(WITH_DYNAREC=arm)
        isPlatform "neon" && params+=(HAVE_NEON=1)
    fi
    if isPlatform "gles3"; then
        params+=(FORCE_GLES3=1)
    elif isPlatform "gles"; then
        params+=(FORCE_GLES=1)
    fi
    make clean
    make "${params[@]}"
    rpSwap off
    md_ret_require="$md_build/mupen64plus_libretro.so"
}

function install_lr-mupen64plus() {
    md_ret_files=(
        'mupen64plus_libretro.so'
        'LICENSE'
        'README.md'
        'BUILDING.md'
    )
}

function configure_lr-mupen64plus() {
    mkRomDir "n64"
    defaultRAConfig "n64"

    addEmulator 0 "$md_id" "n64" "$md_inst/mupen64plus_libretro.so"
    addSystem "n64"
}
