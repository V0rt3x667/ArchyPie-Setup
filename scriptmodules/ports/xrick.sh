#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="xrick"
rp_module_desc="xrick - Open-Source Implementation of Rick Dangerous"
rp_module_licence="GPL https://raw.githubusercontent.com/RetroPie/xrick/master/README"
rp_module_repo="git https://github.com/RetroPie/xrick.git master"
rp_module_section="opt"
rp_module_flags="sdl1 !mali"

function depends_xrick() {
    getDepends sdl sdl_mixer sdl_image zlib
}

function sources_xrick() {
    gitPullOrClone
    # Append ArchLinux Build Flags & Add -fcommon To Allow Building Under GCC11
    sed "s|CFLAGS=|CFLAGS+=-fcommon |;s|LDFLAGS=|LDFLAGS+=|" -i "$md_build/Makefile"
}

function build_xrick() {
    make clean
    make
    md_ret_require="$md_build/xrick"
}

function install_xrick() {
    md_ret_files=(
        'README'
        'xrick'
    )
}

function configure_xrick() {
    addPort "$md_id" "xrick" "XRick" "$md_inst/xrick.sh -fullscreen" "$romdir/ports/xrick/data.zip"

    [[ "$md_mode" == "remove" ]] && return

    # set dispmanx by default on rpi with fkms
    isPlatform "dispmanx" && ! isPlatform "videocore" && setBackend "$md_id" "dispmanx"

    _add_data_lr-xrick

    ln -sf "$romdir/ports/xrick/data.zip" "$md_inst/data.zip"

    local file="$md_inst/xrick.sh"
    cat >"$file" << _EOF_
#!/bin/bash
pushd "$md_inst"
./xrick "\$@"
popd
_EOF_
    chmod +x "$file"
}
