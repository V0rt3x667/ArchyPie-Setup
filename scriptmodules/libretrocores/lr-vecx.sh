#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-vecx"
rp_module_desc="GCE Vectrex Libretro Core"
rp_module_help="ROM Extensions: .vec .gam .bin .zip\n\nCopy your Vectrex roms to $romdir/vectrex"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/libretro-vecx/master/LICENSE.md"
rp_module_repo="git https://github.com/libretro/libretro-vecx master"
rp_module_section="main"

function depends_lr-vecx() {
    local depends=()
    isPlatform "mesa" && depends+=(libglvnd)
    isPlatform "rpi" && depends+=(libraspberrypi-firmware)
    getDepends "${depends[@]}"
}

function sources_lr-vecx() {
    gitPullOrClone
}

function build_lr-vecx() {
    local params
    isPlatform "rpi" && params+="platform=rpi"
    isPlatform "gles" && params+=" HAS_GLES=1"

    make clean
    make -f Makefile.libretro $params
    md_ret_require="$md_build/vecx_libretro.so"
}

function install_lr-vecx() {
    md_ret_files=(
        'vecx_libretro.so'
        'bios/fast.bin'
        'bios/skip.bin'
        'bios/system.bin'
    )
}

function configure_lr-vecx() {
    mkRomDir "vectrex"
    defaultRAConfig "vectrex"

    if [[ "$md_mode" == "install" ]]; then
        # Copy bios files
        cp -v "$md_inst/"{fast.bin,skip.bin,system.bin} "$biosdir/"
        chown "${user}:${user}" "$biosdir/"{fast.bin,skip.bin,system.bin}
    else
        rm -f "$biosdir/"{fast.bin,skip.bin,system.bin}
    fi

    addEmulator 1 "$md_id" "vectrex" "$md_inst/vecx_libretro.so"
    addSystem "vectrex"
}
