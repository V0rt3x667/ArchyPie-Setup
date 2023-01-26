#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mupen64plus-next"
rp_module_desc="Nintendo N64 Libretro Core"
rp_module_help="ROM Extensions: .z64 .n64 .v64\n\nCopy your N64 roms to $romdir/n64"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mupen64plus-libretro-nx/master/LICENSE"
rp_module_repo="git https://github.com/libretro/mupen64plus-libretro-nx develop"
rp_module_section="opt kms=main"
rp_module_flags=""

function depends_lr-mupen64plus-next() {
    local depends=()
    isPlatform "x11" && depends+=(glew libglvnd)
    isPlatform "x86" && depends+=(nasm)
    isPlatform "rpi" && depends+=(raspberrypi-firmware)
    isPlatform "mesa" && depends+=(libglvnd)
    getDepends "${depends[@]}"
}

function sources_lr-mupen64plus-next() {
    gitPullOrClone
}

function build_lr-mupen64plus-next() {
    local params=()
    if isPlatform "arm"; then
        if isPlatform "rpi"; then
            params+=(platform="$__platform")
        elif isPlatform "mesa"; then
            params+=(platform="$__platform-mesa")
        elif isPlatform "mali"; then
            params+=(platform="odroid")
        fi
        if isPlatform "neon"; then
            params+=(HAVE_NEON=1)
        fi
    fi
    if isPlatform "gles3"; then
        params+=(FORCE_GLES3=1)
    elif isPlatform "gles"; then
        params+=(FORCE_GLES=1)
    fi

    # use a custom core name to avoid core option name clashes with lr-mupen64plus
    params+=(CORE_NAME=mupen64plus-next)
    make "${params[@]}" clean
    make "${params[@]}"

    md_ret_require="$md_build/mupen64plus_next_libretro.so"
}

function install_lr-mupen64plus-next() {
    md_ret_files=(
        'mupen64plus_next_libretro.so'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-mupen64plus-next() {
    mkRomDir "n64"
    defaultRAConfig "n64"

    if isPlatform "rpi"; then
        # Disable hybrid upscaling filter (needs better GPU)
        setRetroArchCoreOption "mupen64plus-next-HybridFilter" "False"
        # Disable overscan/VI emulation (slight performance drain)
        setRetroArchCoreOption "mupen64plus-next-EnableOverscan" "Disabled"
        # Enable Threaded GL calls
        setRetroArchCoreOption "mupen64plus-next-ThreadedRenderer" "True"
    fi
    setRetroArchCoreOption "mupen64plus-next-EnableNativeResFactor" "1"

    addEmulator 1 "$md_id" "n64" "$md_inst/mupen64plus_next_libretro.so"
    addSystem "n64"
}
