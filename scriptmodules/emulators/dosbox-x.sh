#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dosbox-x"
rp_module_desc="DOSBox-X - MS-DOS\x86 Emulator Includes Additional Patches & Features"
rp_module_help="ROM Extensions: .bat .com .exe .sh .conf\n\nCopy Your DOS Games to $romdir/pc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/joncampbell123/dosbox-x/master/COPYING"
rp_module_repo="git https://github.com/joncampbell123/dosbox-x.git :_get_branch_dosbox-x"
rp_module_section="main"

function _get_branch_dosbox-x() {
    download https://api.github.com/repos/joncampbell123/dosbox-x/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_dosbox-x() {
    local depends=(
        'alsa-utils'
        'ffmpeg4.4'
        'fluidsynth'
        'glu'
        'libpcap'
        'libpng'
        'libslirp'
        'libxkbfile'
        'libxrandr'
        'mesa'
        'physfs'
    )
    getDepends "${depends[@]}"
}

function sources_dosbox-x() {
    gitPullOrClone
    sed -i 's|"$LIBS -lavcodec -lavformat -lavutil -lswscale "`pkg-config libavcodec --libs`|`pkg-config libavcodec libavformat libavutil libswscale libswresample --libs`"$LIBS"|' configure.ac
}

function build_dosbox-x() {
    ./autogen.sh
    PKG_CONFIG_PATH="/usr/lib/ffmpeg4.4/pkgconfig" ./configure \
        --prefix="$md_inst" \
        --enable-sdl2 \
        --enable-core-inline \
        --disable-debug \
        --enable-avcodec
    make clean
    make
    md_ret_require=("$md_build/src/dosbox-x")
}

function install_dosbox-x() {
    make install
}

function configure_dosbox-x() {
    configure_dosbox

    [[ "$md_id" == "remove" ]] && return

    local config_path=$(su "${user}" -c "\"$md_inst/bin/dosbox-x\" -printconf")
    if [[ -f "$config_path" ]]; then
        iniConfig " = " "" "$config_path"
        if isPlatform "rpi"; then
            iniSet "fullscreen" "true"
            iniSet "fullresolution" "desktop"
            iniSet "output" "texturenb"
            iniSet "core" "dynamic"
            iniSet "cycles" "25000"
        fi
    fi
}
