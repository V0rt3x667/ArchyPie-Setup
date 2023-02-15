#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-dolphin"
rp_module_desc="Nintendo Gamecube & Wii Libretro Core"
rp_module_help="ROM Extensions: .ciso .dff .dol .elf .gcm .gcz .iso .m3u .rvz .tgc .wad .wbfs .wia\n\nCopy Gamecube ROMs To: ${romdir}/gc\nCopy Wii ROMs To: ${romdir}/wii\n\nOPTIONAL: Copy BIOS File (IPL.bin) To:\n${biosdir}/gc/EUR\n${biosdir}/gc/JAP\n${biosdir}/gc/USA"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/dolphin/master/license.txt"
rp_module_repo="git https://github.com/libretro/dolphin master"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function depends_lr-dolphin() {
    local depends=(
        'bluez-libs'
        'cmake'
        'enet'
        'ffmpeg'
        'lzo'
        'mbedtls'
        'miniupnpc'
        'minizip'
        'ninja'
        'pugixml'
        'qt5-base'
        'sfml'
    )
    getDepends "${depends[@]}"
}

function sources_lr-dolphin() {
    gitPullOrClone
}

function build_lr-dolphin() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DENABLE_LTO="OFF" \
        -DENABLE_QT="OFF" \
        -DENABLE_TESTS="OFF" \
        -DLIBRETRO_STATIC="ON" \
        -DLIBRETRO="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/dolphin_libretro.so"
}

function install_lr-dolphin() {
    md_ret_files=(
        'build/dolphin_libretro.so'
        'Data/Sys'
    )
}

function configure_lr-dolphin() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "gc"
        mkRomDir "wii"

        mkUserDir "${biosdir}/gc"
        mkUserDir "${biosdir}/gc/dolphin-emu"

        cp -r "${md_inst}/Sys" "${biosdir}/gc/dolphin-emu"
        chown -R "${user}:${user}" "${biosdir}/gc/dolphin-emu"
    fi

    defaultRAConfig "gc" "system_directory" "${biosdir}/gc"
    defaultRAConfig "wii"

    addEmulator 0 "${md_id}" "gc" "${md_inst}/dolphin_libretro.so"
    addEmulator 0 "${md_id}" "wii" "${md_inst}/dolphin_libretro.so"

    addSystem "gc"
    addSystem "wii"
}
