#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-swanstation"
rp_module_desc="Sony Playstation Libretro Core"
rp_module_help="ROM Extensions: .exe .cue .bin .chd .psf .m3u .pbp\n\nCopy your PlayStation roms to $romdir/psx\n\nCopy compatble BIOS files to $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/swanstation/main/LICENSE"
rp_module_section="exp"
rp_module_repo="git https://github.com/libretro/swanstation main"
rp_module_flags="!all arm aarch64 64bit"

function sources_lr-swanstation() {
    gitPullOrClone
}

function build_lr-swanstation() {
    cmake . -Wno-dev
    make clean
    make
    md_ret_require="$md_build/swanstation_libretro.so"
}

function install_lr-swanstation() {
    md_ret_files=('swanstation_libretro.so')
}

function configure_lr-swanstation() {
    mkRomDir "psx"
    defaultRAConfig "psx"

    if isPlatform "gles" && ! isPlatform "gles3"; then
        # Hardware renderer not supported on GLES2 devices
        setRetroArchCoreOption "swanstation_GPU.Renderer" "Software"
    fi

    # Pi 4 has occasional slowdown with hardware rendering
    # e.g. Gran Turismo 2 (Arcade) race start
    isPlatform "rpi4" && setRetroArchCoreOption "swanstation_GPU.Renderer" "Software"

    addEmulator 0 "$md_id" "psx" "$md_inst/swanstation_libretro.so" 
    addSystem "psx"
}
