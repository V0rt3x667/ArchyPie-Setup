#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dolphin"
rp_module_desc="Dolphin: Nintendo Gamecube & Wii Emulator"
rp_module_help="ROM Extensions: .gcm .iso .wbfs .ciso .gcz .rvz .wad .wbfs\n\nCopy Gamecube ROMs To: ${romdir}/gc\n\nCopy Wii ROMs To ${romdir}/wii"
rp_module_licence="GPL2 https://raw.githubusercontent.com/dolphin-emu/dolphin/master/COPYING"
rp_module_repo="git https://github.com/dolphin-emu/dolphin master"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function depends_dolphin() {
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
        'qt6-base'
        'sfml'
    )
    getDepends "${depends[@]}"
}

function sources_dolphin() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|#define DOLPHIN_DATA_DIR \"dolphin-emu\"|#define DOLPHIN_DATA_DIR \"dolphin\"|g" -i "${md_build}/Source/Core/Common/CommonPaths.h"
}

function build_dolphin() {
    local params=()
    ! isPlatform "x11" && params=('-DENABLE_X11="OFF"')

    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DENABLE_ANALYTICS="OFF" \
        -DENABLE_AUTOUPDATE="OFF" \
        -DUSE_SHARED_ENET="ON" \
        "${params[@]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/Binaries/${md_id}-emu"
}

function install_dolphin() {
    ninja -C build install/strip
}

function configure_dolphin() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/gc/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "gc"
        mkRomDir "wii"

        mkUserDir "${biosdir}/gc"
        mkUserDir "${arpdir}/${md_id}/Config"

        local config

        config="$(mktemp)"
        iniConfig " = " "" "${config}"

        # Set Fullscreen By Default
        echo "[Display]" > "${config}"
        iniSet "FullscreenResolution" "Auto"
        iniSet "Fullscreen" "True"

        copyDefaultConfig "${config}" "${arpdir}/${md_id}/Config/Dolphin.ini"
        rm "${config}"
    fi

    local launcher_prefix="DOLPHIN_EMU_USERPATH=${arpdir}/${md_id}"

    addEmulator 1 "${md_id}" "gc" "${launcher_prefix} $md_inst/bin/${md_id}-emu-nogui -e %ROM%"
    addEmulator 0 "${md_id}-gui" "gc" "${launcher_prefix} $md_inst/bin/${md_id}-emu -b -e %ROM%"
    addEmulator 1 "${md_id}" "wii" "${launcher_prefix} $md_inst/bin/${md_id}-emu-nogui -e %ROM%"
    addEmulator 0 "${md_id}-gui" "wii" "${launcher_prefix} $md_inst/bin/${md_id}-emu -b -e %ROM%"

    addSystem "gc"
    addSystem "wii"
}
