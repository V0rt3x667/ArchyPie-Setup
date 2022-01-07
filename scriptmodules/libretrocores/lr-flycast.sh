#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-flycast"
rp_module_desc="Sega Dreamcast & Naomi Atomiswave Libretro Core"
rp_module_help="Dreamcast ROM Extensions: .cdi .gdi .chd .m3u, Naomi Atomiswave ROM Extension: .zip\n\nCopy your Dreamcast/Naomi roms to $romdir/dreamcast\n\nCopy the required Dreamcast BIOS files dc_boot.bin and dc_flash.bin to $biosdir/dc\n\nCopy the required Naomi/Atomiswave BIOS files naomi.zip and awbios.zip to $biosdir/dc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/flycast/master/LICENSE"
rp_module_repo="git https://github.com/flyinghead/flycast.git master"
rp_module_section="opt"
rp_module_flags="!armv6"

function depends_lr-flycast() {
    local depends=(libzip zlib cmake)
    isPlatform "videocore" && depends+=(libraspberrypi-dev)
    isPlatform "mesa" && depends+=(libgles2-mesa-dev)
    isPlatform "x11" && depends+=(libglvnd)
    getDepends "${depends[@]}"
}

function sources_lr-flycast() {
    gitPullOrClone
}

function build_lr-flycast() {
    local params=("-DLIBRETRO=On -DUSE_HOST_LIBZIP=On -DCMAKE_BUILD_TYPE=Release")
    local add_flags=()
    if isPlatform "gles" && ! isPlatform "gles3" ; then
        if isPlatform "videocore"; then
            add_flags+=("-I/opt/vc/include -DLOW_END")
            params+=("-DUSE_VIDEOCORE=On")
        fi
        params+=("-DUSE_GLES2=On")
    fi

    isPlatform "gles3" && params+=("-DUSE_GLES=On")
    ! isPlatform "x86" && params+=("-DUSE_VULKAN=Off")

    mkdir -p build
    cd build
    CFLAGS="$CFLAGS ${add_flags[@]}" CXXFLAGS="$CXXFLAGS ${add_flags}" cmake "${params[@]}" ..
    make
    md_ret_require="$md_build/build/flycast_libretro.so"
}

function install_lr-flycast() {
    md_ret_files=(
        'build/flycast_libretro.so'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-flycast() {
    mkRomDir "dreamcast"
    ensureSystemretroconfig "dreamcast"

    mkUserDir "$biosdir/dc"

    # system-specific
    if isPlatform "gl"; then
        iniConfig " = " "" "$configdir/dreamcast/retroarch.cfg"
        iniSet "video_shared_context" "true"
    fi

    local def=0
    isPlatform "kms" && def=1
    # segfaults on the rpi without redirecting stdin from </dev/null
    addEmulator $def "$md_id" "dreamcast" "$md_inst/flycast_libretro.so </dev/null"
    addSystem "dreamcast"
}
