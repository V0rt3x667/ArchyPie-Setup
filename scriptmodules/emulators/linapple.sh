#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="linapple"
rp_module_desc="LinApple-Pie - Apple 2 & 2e Emulator"
rp_module_help="ROM Extensions: .dsk\n\nCopy your Apple 2 games to $romdir/apple2"
rp_module_licence="GPL2 https://raw.githubusercontent.com/dabonetn/linapple-pie/master/LICENSE"
rp_module_repo="git https://github.com/dabonetn/linapple-pie.git master"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_linapple() {
    getDepends libzip sdl sdl_image curl
}

function sources_linapple() {
    gitPullOrClone
}

function build_linapple() {
    cd src
    make clean
    make
    md_ret_require="$md_build/linapple"
}

function install_linapple() {
    md_ret_files=(
        'CHANGELOG'
        'INSTALL'
        'LICENSE'
        'linapple'
        'linapple.conf'
        'Master.dsk'
        'README'
        'README-linapple-pie'
    )
}

function configure_linapple() {
    mkRomDir "apple2"

    addEmulator 1 "$md_id" "apple2" "$md_inst/linapple.sh -1 %ROM%"
    addSystem "apple2"

    [[ "$md_mode" == "remove" ]] && return

    # copy default config/disk if user doesn't have them installed
    local file
    for file in Master.dsk linapple.conf; do
        copyDefaultConfig "${file}" "$md_conf_root/apple2/${file}"
    done

    isPlatform "dispmanx" && setBackend "$md_id" "dispmanx"

    mkUserDir "$md_conf_root/apple2"
    moveConfigDir "$home/.linapple" "$md_conf_root/apple2"

    local file="$md_inst/linapple.sh"
    cat >"${file}" << _EOF_
#!/bin/bash
pushd "$romdir/apple2"
$md_inst/linapple "\$@"
popd
_EOF_
    chmod +x "${file}"
}
