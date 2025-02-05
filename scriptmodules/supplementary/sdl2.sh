#!/bin/bash

################################################################################
# This file is part of the ArchyPie Project                                    #
#                                                                              #
# Please see the LICENSE file at the top-level directory of this distribution. #
################################################################################

rp_module_id="sdl2"
rp_module_desc="SDL2: Simple DirectMedia Layer v2.x with RPI fixes for KMS"
rp_module_help="Simple DirectMedia Layer (SDL) (Required by Emulators & Ports)"
rp_module_licence="ZLIB https://raw.githubusercontent.com/libsdl-org/SDL/main/LICENSE.txt"
rp_module_repo="git https://github.com/libsdl-org/SDL.git :_get_release_sdl2"
rp_module_section="depends"
rp_module_flags="!all kms"

function _get_release_sdl2() {
    local release="2.30.11"
    echo "${release}"
}

function depends_sdl2() {
    local depends=(
        'alsa-lib'
        'clang'
        'cmake'
        'fcitx5'
        'glibc'
        'hidapi'
        'ibus'
        'jack'
        'libdecor'
        'libgl'
        'libpulse'
        'libusb'
        'libx11'
        'libxcursor'
        'libxext'
        'libxinerama'
        'libxkbcommon'
        'libxrandr'
        'libxrender'
        'libxss'
        'mesa'
        'mold'
        'ninja'
        'pipewire'
        'wayland-protocols'
        'wayland'
    )
    getDepends "${depends[@]}"
}

function sources_sdl2() {
    gitPullOrClone

    # Adds RetroPie custom KMS hints
    applyPatch "${md_data}/01_add_kms_hints.patch"
}

function build_sdl2() {
#     isPlatform "vulkan" && conf_flags+=("--enable-video-vulkan") || conf_flags+=("--disable-video-vulkan")
#     isPlatform "mali" && conf_flags+=("--enable-video-mali" "--disable-video-opengl")
#     isPlatform "kms" || isPlatform "rpi" && conf_flags+=("--enable-video-kmsdrm")

    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_C_FLAGS="${CFLAGS} -ffat-lto-objects" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_LINKER_TYPE="MOLD" \
        -DSDL_KMSDRM_SHARED="ON" \
        -DSDL_KMSDRM="ON" \
        -DSDL_RPATH="OFF" \
        -DSDL_RPI="OFF" \
        -DSDL_STATIC="OFF" \
        -Wno-dev
    ninja -C build clean
    ninja -C build

    #md_ret_require="${md_build}/libSDL2-2.0.so.$(_release_sdl2)"
}

function install_sdl2() {
    ninja -C build install/strip

    install -Dm644 "LICENSE.txt" "${md_inst}/LICENSE"
}

#function configure_sdl2() {
#    ldconfig -nN "${md_inst}"
#}
