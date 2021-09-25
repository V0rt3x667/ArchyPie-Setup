#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="rpcs3"
rp_module_desc="RPCS3 - Sony PlayStation 3 Emulator"
rp_module_help="ROM Extensions: .iso .pkg\n\nCopy Your Sony PlayStation 3 Games to $romdir/ps3"
rp_module_licence="GPL2 https://raw.githubusercontent.com/RPCS3/rpcs3/master/LICENSE"
rp_module_repo="git https://github.com/RPCS3/rpcs3.git master"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function depends_rpcs3() {
    local depends=(
        'alsa-lib'
        'cmake'
        'ffmpeg'
        'flatbuffers'
        'git'
        'glew'
        'glu'
        'libevdev'
        'libgl'
        'libglvnd'
        'libice'
        'libpng'
        'libpulse'
        'libsm'
        'libx11'
        'libxext'
        'ninja'
        'openal'
        'pugixml'
        'python'
        'qt5-base'
        'qt5-declarative'
        'sdl2'
        'vulkan-icd-loader'
        'vulkan-validation-layers'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_rpcs3() {
    gitPullOrClone
}

function build_rpcs3() {
    cmake . \
        -GNinja \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DUSE_SYSTEM_FFMPEG=ON \
        -DUSE_SYSTEM_LIBPNG=ON \
        -DUSE_SYSTEM_ZLIB=ON \
        -DUSE_SYSTEM_CURL=ON \
        -DUSE_SYSTEM_FLATBUFFERS=ON \
        -DUSE_SYSTEM_PUGIXML=ON \
        -Wno-dev
    ninja -C build
    md_ret_require="$md_build/build/bin/rpcs3"
}

function install_rpcs3() {
    ninja -C build install/strip
}

function configure_rpcs3() {
    mkRomDir "ps3"

    moveConfigDir "$home/.config/rpcs3" "$md_conf_root/ps3"
    ln -snf "$romdir/ps3" "$md_conf_root/ps3/dev_hdd0"

    addEmulator 1 "$md_id" "ps3" "$md_inst/bin/rpcs3 %ROM%"

    addSystem "ps3"
}
