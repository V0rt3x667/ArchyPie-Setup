#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ppsspp"
rp_module_desc="PPSSPP: Sony PlayStation Portable Emulator"
rp_module_help="ROM Extensions: .cso .iso .pbp\n\nCopy PlayStation Portable ROMs To: ${romdir}/psp"
rp_module_licence="GPL2 https://raw.githubusercontent.com/hrydgard/ppsspp/master/LICENSE.TXT"
rp_module_repo="git https://github.com/hrydgard/ppsspp :_get_branch_ppsspp"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_ppsspp() {
    download "https://api.github.com/repos/hrydgard/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
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
    isPlatform "rpi" && depends+=('raspberrypi-firmware')
    isPlatform "mesa" && depends+=('libglvnd')
    isPlatform "x11" || isPlatform "wayland" && depends+=('spirv-tools')
    getDepends "${depends[@]}"
}

function sources_ppsspp() {
    gitPullOrClone

    # Set Default Config Path(s)
    if [[ "${md_id}" == "ppsspp" || "${md_id}" == "ppsspp-1.5.4" ]]; then
        sed -e "s|\"/.config\"|\"/ArchyPie/configs\"|g" -i "${md_build}/UI/NativeApp.cpp"
    fi
}

function build_ppsspp() {
    local binary="PPSSPPSDL"
    local params=()

    if isPlatform "mesa"; then
        params+=('-DUSING_GLES2=ON' '-DUSING_EGL=OFF')
    elif isPlatform "mali"; then
        params+=('-DUSING_GLES2=ON' '-DUSING_FBDEV=ON')
    fi

    isPlatform "x86" && isPlatform "32bit" && params+=('-DX86=ON' '-DX86_64=OFF')
    isPlatform "x86" && isPlatform "64bit" && params+=('-DX86=OFF' '-DX86_64=ON')
    isPlatform "wayland" && params+=('-DUSING_X11_VULKAN=OFF' '-DUSE_WAYLAND_WSI=ON')

    if [[ "${md_id}" == "lr-ppsspp" ]]; then
        params+=('-DLIBRETRO=On')
        binary="lib/ppsspp_libretro.so"
    fi

    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DBUILD_TESTING="OFF" \
        -DHEADLESS="ON" \
        -DUSE_SYSTEM_LIBZIP="ON" \
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
    ninja -C build install/strip
}

function configure_ppsspp() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/psp/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "psp"
        mkUserDir "${md_conf_root}/psp/${md_id}/PSP"
        ln -snf "${romdir}/psp" "${md_conf_root}/psp/${md_id}/PSP/GAME"
    fi

    local params=()
    if isPlatform "x11" || isPlatform "wayland"; then
        params+=('--fullscreen')
    fi

    addEmulator 1 "${md_id}" "psp" "pushd ${md_inst}; ${md_inst}/bin/PPSSPPSDL ${params[*]} %ROM%; popd"

    addSystem "psp"

    # if we are removing the last remaining psp emu - remove the symlink
    # if [[ "$md_mode" == "remove" ]]; then
    #     if [[ -h "$home/.config/ppsspp" && ! -f "$md_conf_root/psp/emulators.cfg" ]]; then
    #         rm -f "$home/.config/ppsspp"
    #     fi
    # fi
}
