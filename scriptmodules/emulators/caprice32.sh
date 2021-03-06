#!/usr/bin/env bash

# This file is part of the Arch project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="caprice32"
rp_module_desc="Caprice32 - Amstrad CPC 464, 664 & 6128 Emulator"
rp_module_help="ROM Extensions: .cdt .cpr .dsk .ipf .sna .voc .zip\n\nCopy Your Amstrad CPC Games to: $romdir/amstradcpc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/ColinPitrat/caprice32/master/COPYING.txt"
rp_module_repo="git https://github.com/ColinPitrat/caprice32 master"
rp_module_section="main"

function depends_caprice32() {
    local depends=(
        'freetype2'
        'libpng'
        'sdl2'
        'sdl2_image'
        'sdl2_ttf'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_caprice32() {
    gitPullOrClone
    # Configure Default ROM and Resources Paths
    sed -e "s|\prefix = /usr/local|prefix = ${md_inst}|g" -i ./makefile
    sed -e "s|rom_path=.*|rom_path=${md_inst}/rom|g" -i ./cap32.cfg
    sed -e "s|cart_path=.*|cart_path=${md_inst}/rom|g" -i ./cap32.cfg
    sed -e "s|resources_path=.*|resources_path=${md_inst}/resources|g" -i ./cap32.cfg
    # Enable Full Screen by Default
    sed -e "s|scr_window=1|scr_window=0|g" -i ./cap32.cfg

    downloadAndExtract "http://softpres.org/_media/files:ipflib42_linux-x86_64.tar.gz" "$md_build/capsimage" --strip-components 1
    # Copy CAPSImg Header Files
    mkdir -p "$md_build/src/caps"
    cp capsimage/include/caps/*.h -t "$md_build/src/caps"
}

function build_caprice32() {
    make clean
    make \
        LDFLAGS="${LDFLAGS}" \
        ARCH=linux \
        RELEASE=TRUE \
        APP_PATH="~/.config/caprice32" \
        WITH_IPF=TRUE
    md_ret_require="$md_build"
}

function install_caprice32() {
    md_ret_files=(
        'cap32'
        'cap32.cfg'
        'capsimage/libcapsimage.so.4.2'
        'resources'
        'rom'
        'README.md'
    )
}

function configure_caprice32() {
    moveConfigDir "$home/.config/caprice32" "$md_conf_root/amstradcpc"
    
    addEmulator 1 "$md_id" "amstradcpc" "$md_inst/cap32 %ROM%"
    addSystem "amstradcpc"

    [[ "$md_mode" == "remove" ]] && return

    cp "$md_inst/cap32.cfg" "$md_conf_root/amstradcpc"
    chown "$user:$user" "$md_conf_root/amstradcpc/cap32.cfg"
}
