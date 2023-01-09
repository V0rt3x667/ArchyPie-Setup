#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dolphin"
rp_module_desc="Dolphin - Nintendo Gamecube, Wii & Triforce Emulator"
rp_module_help="ROM Extensions: .gcm .iso .wbfs .ciso .gcz .rvz .wad .wbfs\n\nCopy Your Gamecube ROMs to: $romdir/gc and Wii ROMs to $romdir/wii"
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
        'qt5-base'
        'sfml'
    )
    getDepends "${depends[@]}"
}

function sources_dolphin() {
    gitPullOrClone
}

function build_dolphin() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DUSE_SHARED_ENET=ON \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/Binaries/dolphin-emu"
}

function install_dolphin() {
    ninja -C build install/strip
}

function configure_dolphin() {
    mkRomDir "gc"
    mkRomDir "wii"

    moveConfigDir "$home/.dolphin-emu" "$md_conf_root/gc"

    if [[ ! -f "$md_conf_root/gc/Config/Dolphin.ini" ]]; then
        mkdir -p "$md_conf_root/gc/Config"
        cat >"$md_conf_root/gc/Config/Dolphin.ini" <<_EOF_
[Display]
FullscreenResolution = Auto
Fullscreen = True
_EOF_
        chown -R "${user}:${user}" "$md_conf_root/gc/Config"
    fi

    addEmulator 1 "$md_id" "gc" "$md_inst/bin/dolphin-emu-nogui -e %ROM%"
    addEmulator 0 "$md_id-gui" "gc" "$md_inst/bin/dolphin-emu -b -e %ROM%"
    addEmulator 1 "$md_id" "wii" "$md_inst/bin/dolphin-emu-nogui -e %ROM%"
    addEmulator 0 "$md_id-gui" "wii" "$md_inst/bin/dolphin-emu -b -e %ROM%"

    addSystem "gc"
    addSystem "wii"
}
