#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="hatari"
rp_module_desc="Hatari - Atari ST, STE, TT & Falcon Emulator"
rp_module_help="ROM Extensions: .st .stx .img .rom .raw .ipf .ctr .zip\n\nCopy your Atari ST games to $romdir/atarist\n\nCopy Atari ST BIOS (tos.img) to $biosdir"
rp_module_licence="GPL2 https://git.tuxfamily.org/hatari/hatari.git/plain/gpl.txt"
rp_module_repo="git https://github.com/hatari/hatari.git master"
rp_module_section="opt"
rp_module_flags=""

function depends_hatari() {
    local depends=(
        'cmake'
        'libpng'
        'ninja'
        'portaudio'
        'readline'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}" 
}

function _sources_libcapsimage_hatari() {
    downloadAndExtract "$__archive_url/spsdeclib_5.1_source.zip" "$md_build"
    unzip -o capsimg_source_linux_macosx.zip
    chmod u+x capsimg_source_linux_macosx/CAPSImg/configure
}

function sources_hatari() {
    gitPullOrClone
    _sources_libcapsimage_hatari
}

function _build_libcapsimage_hatari() {
    # build libcapsimage
    cd capsimg_source_linux_macosx/CAPSImg
    ./configure --prefix="$md_build"
    make clean
    make
    make install
    mkdir -p "$md_build/src/includes/caps"
    cp -R "../LibIPF/"*.h "$md_build/src/includes/caps/"
    cp "../Core/CommonTypes.h" "$md_build/src/includes/caps/"
    # 'lr-hatari' expects a 'caps5' include path
    ln -sf "$md_build/src/includes/caps" "$md_build/src/includes/caps5"
}

function build_hatari() {
    _build_libcapsimage_hatari
    cmake . \
        -S"$md_build" \
        -B"$md_build/build" \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -Wl,-rpath='$md_inst/lib'" \
        -DCAPSIMAGE_INCLUDE_DIR="$md_build/src/includes" \
        -DCAPSIMAGE_LIBRARY="$md_build/lib/libcapsimage.so.5.1" \
        -Wno-dev
    ninja -C "$md_build/build" clean
    ninja -C "$md_build/build"
    md_ret_require="$md_build/build/src/hatari"
}

function _install_libcapsimage_hatari() {
    install -Dm644 "$md_build/lib/libcapsimage.so.5.1" -t "$md_inst/lib"
    ln -sf "$md_inst/lib/libcapsimage.so.5.1" "$md_inst/lib/libcapsimage.so.5"
}

function install_hatari() {
    ninja -C build install/strip
    _install_libcapsimage_hatari
}

function configure_hatari() {
    mkRomDir "atarist"

    local common_config=("--confirm-quit 0" "--statusbar 0")
    if ! isPlatform "x11"; then
        common_config+=("--zoom 1" "-w")
    else
        common_config+=("-f")
    fi

    addEmulator 1 "$md_id-fast" "atarist" "$md_inst/bin/hatari ${common_config[*]} --compatible 0 --timer-d 1 --borders 0 %ROM%"
    addEmulator 0 "$md_id-fast-borders" "atarist" "$md_inst/bin/hatari ${common_config[*]} --compatible 0 --timer-d 1 --borders 1 %ROM%"
    addEmulator 0 "$md_id-compatible" "atarist" "$md_inst/bin/hatari ${common_config[*]} --compatible 1 --timer-d 0 --borders 0 %ROM%"
    addEmulator 0 "$md_id-compatible-borders" "atarist" "$md_inst/bin/hatari ${common_config[*]} --compatible 1 --timer-d 0 --borders 1 %ROM%"
    addSystem "atarist"

    [[ "$md_mode" == "remove" ]] && return

    moveConfigDir "$home/.hatari" "$md_conf_root/atarist"

    ln -sf "$biosdir/tos.img" "$md_inst/share/hatari/tos.img"
}
