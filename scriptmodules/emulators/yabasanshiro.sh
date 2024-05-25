#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="yabasanshiro"
rp_module_desc="Yaba Sanshiro: SEGA Saturn Emulator"
rp_module_help="ROM Extensions: .cue .chd\n\nCopy SEGA Saturn ROMs To: ${romdir}/saturn"
rp_module_licence="GPL2 https://raw.githubusercontent.com/devmiyax/yabause/master/LICENSE"
rp_module_repo="git https://github.com/devmiyax/yabause pi4-1-9-0"
rp_module_section="exp"
rp_module_flags="!all rpi"

function depends_yabasanshiro() {
    local depends=(
        'boost-libs'
        'clang'
        'cmake'
        'doxygen'
        'libsecret'
        'lld'
        'ninja'
        'openssl'
        'protobuf'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_yabasanshiro() {
    gitPullOrClone
}

function build_yabasanshiro() {
    local params=()

    isPlatform "32bit" && params+=(-DCMAKE_SYSTEM_PROCESSOR="armv7-a")
    isPlatform "64bit" && params+=(-DCMAKE_SYSTEM_PROCESSOR="aarch64")
    isPlatform "vulkan" && params+=(-DYAB_WANT_VULKAN="ON")

    export CFLAGS="${CFLAGS} -D_POSIX_C_SOURCE=199309L -D__PI4__ -D__RETORO_ARENA__"
    export CXXFLAGS="${CXXFLAGS} -D__PI4__ -D__RETORO_ARENA_"

    cmake . \
        -B"build" \
        -G"Ninja" \
        -S"yabause" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DGIT_EXECUTABLE="/usr/bin/git" \
        -DUSE_EGL="ON" \
        -DYAB_PORTS="retro_arena" \
        -DYAB_WANT_ARM7="ON" \
        -DYAB_WANT_DYNAREC_DEVMIYAX="ON" \
        -DYAB_WANT_OPENAL="OFF" \
        "${params[@]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/src/retro_arena/yabasanshiro"
}

function install_yabasanshiro() {
    ninja -C build install/strip
}

function configure_yabasanshiro() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/saturn/${md_id}"

    [[ "${md_mode}" == "install" ]] && mkRomDir "saturn"

    addEmulator 1 "${md_id}" "saturn" "${md_inst}/yabasanshiro -r 3 -i %ROM%"

    addSystem "saturn"
}
