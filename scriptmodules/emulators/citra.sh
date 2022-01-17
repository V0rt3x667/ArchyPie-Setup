#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="citra"
rp_module_desc="Citra - Nintendo 3DS Emulator"
rp_module_help="ROM Extensions: .3ds .3dsx .app .axf .cci .cxi .elf\n\nCopy Your Decrypted Nintendo 3DS Games to $romdir/3ds"
rp_module_licence="GPL2 https://raw.githubusercontent.com/citra-emu/citra/master/license.txt"
rp_module_repo="git https://github.com/citra-emu/citra master"
rp_module_section="main"
rp_module_flags="!all 64bit"

function depends_citra() {
    local depends=(
        'boost'
        'cmake'
        'doxygen'
        'ffmpeg'
        'fmt'
        'libfdk-aac'
        'ninja'
        'qt5-base'
        'qt5-multimedia'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_citra() {
    gitPullOrClone
}

function build_citra() {
    cmake . \
        -GNinja \
        -Bbuild \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DENABLE_FFMPEG_AUDIO_DECODER=ON \
        -DCITRA_USE_BUNDLED_SDL2=OFF \
        -Wno-dev
    ninja -C build
    md_ret_require="$md_build/build/bin/Release/citra"
}

function install_citra() {
    ninja -C build install/strip
}

function configure_citra() {
    mkRomDir "3ds"

    moveConfigDir "$home/.local/share/citra-emu" "$md_conf_root/3ds/citra"

    addEmulator 1 "$md_id" "3ds" "$md_inst/bin/citra -f %ROM%"
    addEmulator 0 "$md_id-gui" "3ds" "$md_inst/bin/citra-qt -f %ROM%"

    addSystem "3ds"
}
