#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ppsspp"
rp_module_desc="PPSSPP - Sony PlayStation Portable Emulator"
rp_module_help="ROM Extensions: .iso .pbp .cso\n\nCopy your PlayStation Portable roms to $romdir/psp"
rp_module_licence="GPL2 https://raw.githubusercontent.com/hrydgard/ppsspp/master/LICENSE.TXT"
rp_module_repo="git https://github.com/hrydgard/ppsspp.git :_get_branch_ppsspp"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_ppsspp() {
    download https://api.github.com/repos/hrydgard/ppsspp/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_ppsspp() {
    local depends=(
        'cmake'
        'libzip'
        'ninja'
        'sdl2'
        'snappy'
        'zlib'
    )
    isPlatform "videocore" && depends+=(libraspberrypi-firmware)
    isPlatform "mesa" && depends+=(libglvnd)
    getDepends "${depends[@]}"
}

function sources_ppsspp() {
    gitPullOrClone
}

function build_ppsspp() {
    local ppsspp_binary="PPSSPPSDL"
    rm -rf CMakeCache.txt CMakeFiles
    local params=()
    if isPlatform "videocore"; then
        params+=(-DCMAKE_TOOLCHAIN_FILE=cmake/Toolchains/raspberry.armv7.cmake)
    elif isPlatform "mesa"; then
        params+=(-DUSING_GLES2=ON -DUSING_EGL=OFF)
    elif isPlatform "mali"; then
        params+=(-DUSING_GLES2=ON -DUSING_FBDEV=ON)
        # remove -DGL_GLEXT_PROTOTYPES on odroid-xu/tinker to avoid errors due to header prototype differences
        params+=(-DCMAKE_C_FLAGS="${CFLAGS/-DGL_GLEXT_PROTOTYPES/}")
        params+=(-DCMAKE_CXX_FLAGS="${CXXFLAGS/-DGL_GLEXT_PROTOTYPES/}")
    elif isPlatform "tinker"; then
        params+=(-DCMAKE_TOOLCHAIN_FILE="$md_data/tinker.armv7.cmake")
    fi
    if isPlatform "arm" && ! isPlatform "x11"; then
        params+=(-DARM_NO_VULKAN=ON)
    fi
    if [[ "$md_id" == "lr-ppsspp" ]]; then
        params+=(-DLIBRETRO=On)
        ppsspp_binary="lib/ppsspp_libretro.so"
    fi
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        "${params[@]}" \
        -Wno-dev
    ninja -C build
    md_ret_require="$md_build/build/$ppsspp_binary"
}

function install_ppsspp() {
    ninja -C build install/strip
}

function configure_ppsspp() {
    local extra_params=()
    if isPlatform "x11"; then
        extra_params+=(--fullscreen)
    fi

    mkRomDir "psp"
    moveConfigDir "$home/.config/ppsspp" "$md_conf_root/psp"
    mkUserDir "$md_conf_root/psp/PSP"
    ln -snf "$romdir/psp" "$md_conf_root/psp/PSP/GAME"

    addEmulator 0 "$md_id" "psp" "pushd $md_inst; $md_inst/bin/PPSSPPSDL ${extra_params[*]} %ROM%; popd"
    addSystem "psp"
}
