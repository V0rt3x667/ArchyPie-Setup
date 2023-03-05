#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="yabasanshiro"
rp_module_desc="Yaba Sanshiro: SEGA Saturn Emulator "
rp_module_help="ROM Extensions: .cue .chd\n\nCopy SEGA Saturn ROMs To: ${romdir}/saturn"
rp_module_licence="GPL2 https://github.com/devmiyax/yabause/blob/master/LICENSE"
rp_module_repo="git https://github.com/devmiyax/yabause pi4-1-9-0"
rp_module_section="exp"
rp_module_flags="!all rpi4"

# function _get_branch_yabasanshiro() {
#     local branch

#     isPlatform "rpi4" && branch="pi4-1-9-0"
#     echo "${branch}"
# }

function depends_yabasanshiro() {
    local depends=(
        'boost-libs'
        'cmake' 
        'libsecret'
        'ninja'
        'openssl'
        'protobuf'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_yabasanshiro() {
    gitPullOrClone
}

function build_yabasanshiro() {
    local params=()
    isPlatform "rpi4" && params+=('-DYAB_PORTS=retro_arena' '-DYAB_WANT_DYNAREC_DEVMIYAX=ON' '-DYAB_WANT_ARM7=ON' '-DCMAKE_TOOLCHAIN_FILE=../yabause/src/retro_arena/pi4.cmake')
    isPlatform "vulkan" && params+=('-DYAB_WANT_VULKAN=ON')

    cmake . \
        -B"build" \
        -G"Ninja" \
        -S"yabause" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DGIT_EXECUTABLE="/usr/bin/git" \
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
