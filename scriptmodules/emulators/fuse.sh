#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="fuse"
rp_module_desc="Fuse - ZX Spectrum Emulator"
rp_module_help="ROM Extensions: .sna .szx .z80 .tap .tzx .gz .udi .mgt .img .trd .scl .dsk .zip\n\nCopy your ZX Spectrum games to $romdir/zxspectrum"
rp_module_licence="GPL2 https://sourceforge.net/p/fuse-emulator/fuse/ci/master/tree/COPYING"
rp_module_repo="file https://sourceforge.net/projects/fuse-emulator/files/fuse/1.6.0/fuse-1.6.0.tar.gz"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_fuse() {
    getDepends sdl libpng zlib lbzip2 audiofile bison flex
}

function sources_fuse() {
    downloadAndExtract "$md_repo_url" "$md_build" --strip-components 1
    downloadAndExtract "https://sourceforge.net/projects/fuse-emulator/files/libspectrum/1.5.0/libspectrum-1.5.0.tar.gz" "$md_build/libspectrum" --strip-components 1
    if ! isPlatform "x11"; then
        applyPatch "$md_data/01_disable_cursor.diff"
    fi
}

function _build_libspectrum_fuse() {
    cd "$md_build/libspectrum"
    ./configure --disable-shared
    make clean
    make
}

function build_fuse() {
    _build_libspectrum_fuse

    cd "$md_build"
    ./autogen
    ./configure LIBSPECTRUM_CFLAGS="-I$md_build/libspectrum" LIBSPECTRUM_LIBS="-L$md_build/libspectrum/.libs -lspectrum" \
        --prefix="$md_inst" \
        --without-libao \
        --without-gpm \
        --without-gtk \
        --without-libxml2 \
        --with-sdl
    make clean
    make
    md_ret_require="$md_build/fuse"
}

function install_fuse() {
    make install
}

function configure_fuse() {
    mkRomDir "zxspectrum"

    addEmulator 0 "$md_id-48k" "zxspectrum" "$md_inst/bin/fuse --machine 48 --full-screen %ROM%"
    addEmulator 0 "$md_id-128k" "zxspectrum" "$md_inst/bin/fuse --machine 128 --full-screen %ROM%"
    addSystem "zxspectrum"

    [[ "$md_mode" == "remove" ]] && return

    mkUserDir "$md_conf_root/zxspectrum"
    moveConfigFile "$home/.fuserc" "$md_conf_root/zxspectrum/.fuserc"

    # default to dispmanx backend
    isPlatform "dispmanx" && _backend_set_fuse "dispmanx"

    local script="$romdir/zxspectrum/+Start Fuse.sh"
    cat > "$script" << _EOF_
#!/bin/bash
$md_inst/bin/fuse --machine 128 --full-screen
_EOF_
    chown "${user}:${user}" "$script"
    chmod +x "$script"
}

function _backend_set_fuse() {
    local mode="$1"
    local force="$2"
    setBackend "$md_id" "$mode" "$force"
    setBackend "$md_id-48k" "$mode" "$force"
    setBackend "$md_id-128k" "$mode" "$force"
}
