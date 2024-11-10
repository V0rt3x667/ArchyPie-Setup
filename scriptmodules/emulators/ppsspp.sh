#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ppsspp"
rp_module_desc="PPSSPP: Sony PlayStation Portable Emulator"
rp_module_help="ROM Extensions: .chd .cso .elf .iso .pbp .prx\n\nCopy PlayStation Portable ROMs To: ${romdir}/psp"
rp_module_licence="GPL2 https://raw.githubusercontent.com/hrydgard/ppsspp/master/LICENSE.TXT"
rp_module_repo="git https://github.com/hrydgard/ppsspp :_get_branch_ppsspp"
rp_module_section="opt"
rp_module_flags="all"

function _get_branch_ppsspp() {
    echo "v1.18.1"
}

function depends_ppsspp() {
    local depends=(
        'clang'
        'cmake'
        'glew'
        'glslang'
        'libglvnd'
        'libpng'
        'libzip'
        'lld'
        'miniupnpc'
        'ninja'
        'sdl2_ttf'
        'sdl2'
        'snappy'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_ppsspp() {
    gitPullOrClone

    # Set Default Config Path(s)
    if [[ "${md_id}" == "ppsspp" ]]; then
        sed -e "s|\"/.config\"|\"/ArchyPie/configs\"|g" -i "${md_build}/UI/NativeApp.cpp"
    fi
}

function build_ppsspp() {
    local binary="PPSSPPSDL"
    local params=()

    isPlatform "arm"  && ! isPlatform "vulkan" && params+=('-DARM_NO_VULKAN=ON' '-DUSING_X11_VULKAN=OFF')
    isPlatform "kms"  && params+=('-DUSE_WAYLAND_WSI=OFF')
    isPlatform "mali" && params+=('-DUSING_GLES2=ON' '-DUSING_FBDEV=ON')
    isPlatform "mesa" && params+=('-DUSING_GLES2=ON' '-DUSING_EGL=OFF')
    isPlatform "x11"  && params+=('-DUSE_WAYLAND_WSI=ON' '-DUSING_X11_VULKAN=ON')
    isPlatform "x86"  && isPlatform "32bit" && params+=('-DX86=ON' '-DX86_64=OFF')
    isPlatform "x86"  && isPlatform "64bit" && params+=('-DX86=OFF' '-DX86_64=ON')

    if [[ "${md_id}" == "lr-ppsspp" ]]; then
        params+=('-DLIBRETRO=ON')
        binary="lib/ppsspp_libretro.so"
    fi

    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_LINKER_TYPE="LLD" \
        -DBUILD_TESTING="OFF" \
        -DENABLE_CTEST="OFF" \
        -DHEADLESS="OFF" \
        -DUSE_DISCORD="OFF" \
        -DUSE_FFMPEG="ON" \
        -DUSE_SYSTEM_FFMPEG="OFF" \
        -DUSE_SYSTEM_LIBPNG="ON" \
        -DUSE_SYSTEM_LIBZIP="ON" \
        -DUSE_SYSTEM_MINIUPNPC="ON" \
        -DUSE_SYSTEM_SNAPPY="ON" \
        -DUSE_SYSTEM_ZSTD="ON" \
        -DUSING_QT_UI="OFF" \
        "${params[@]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${binary}"
}

function install_ppsspp() {
    md_ret_files=(
        'build/assets'
        'build/PPSSPPSDL'
    )
}

function configure_ppsspp() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/psp/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "psp"
        mkUserDir "${md_conf_root}/psp/${md_id}/PSP"
        ln -snf "${romdir}/psp" "${md_conf_root}/psp/${md_id}/PSP/GAME"
    fi

    local params=()
    if isPlatform "x11"; then
        params+=('--fullscreen')
    fi

    addEmulator 0 "${md_id}" "psp" "${md_inst}/PPSSPPSDL ${params[*]} %ROM%"

    addSystem "psp"
}
