#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="alephone"
rp_module_desc="AlephOne - Marathon Game Engine"
rp_module_help="To get the games running on the Raspberry Pi/Odroid, make sure to set each game to use the software renderer and disable the enhanced HUD from the Plugins menu. For Marathon 1, disable both HUDs from the Plugins menu, start a game, quit back to the title screen and enable Enhanced HUD and it will work and properly."
rp_module_licence="GPL3 https://raw.githubusercontent.com/Aleph-One-Marathon/alephone/master/COPYING"
rp_module_repo="git https://github.com/Aleph-One-Marathon/alephone.git :_get_branch_alephone"
rp_module_section="opt"
rp_module_flags="!mali"

function _get_branch_alephone() {
    download https://api.github.com/repos/Aleph-One-Marathon/alephone/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_alephone() {
    local depends=(
        'boost'
        'ffmpeg'
        'glu'
        'icoutils'
        'libmad'
        'libvorbis'
        'mesa'
        'sdl2_image'
        'sdl2_net'
        'sdl2_ttf'
        'zziplib'
    )
    getDepends "${depends[@]}"
}

function sources_alephone() {
    gitPullOrClone
}

function build_alephone() {
    params=(--prefix="$md_inst")
    isPlatform "arm" && params+=(--with-boost-libdir=/usr/lib/arm-linux-gnueabihf)
    ./autogen.sh
    ./configure "${params[@]}"
    make clean
    make
    md_ret_require="$md_build/Source_Files/alephone"
}

function install_alephone() {
    make install
}

function _game_data_alephone() {
  local release_url
  release_url="https://github.com/Aleph-One-Marathon"

  if [[ ! -f "$romdir/ports/alephone/Marathon/Shapes.shps" ]]; then
    downloadAndExtract "$release_url/data-marathon/archive/master.zip" "$romdir/ports/alephone"
    mv "$romdir/ports/alephone/data-marathon-master" "$romdir/ports/alephone/Marathon"
  fi

  if [[ ! -f "$romdir/ports/alephone/Marathon 2/Shapes.shpA" ]]; then
    downloadAndExtract "$release_url/data-marathon-2/archive/master.zip" "$romdir/ports/alephone"
    mv "$romdir/ports/alephone/data-marathon-2-master" "$romdir/ports/alephone/Marathon 2"
  fi

  if [[ ! -f "$romdir/ports/alephone/Marathon Infinity/Shapes.shpA" ]]; then
    downloadAndExtract "$release_url/data-marathon-infinity/archive/master.zip" "$romdir/ports/alephone"
    mv "$romdir/ports/alephone/data-marathon-infinity-master" "$romdir/ports/alephone/Marathon Infinity"
  fi

  chown -R "$user:$user" "$romdir/ports/alephone"
}

function configure_alephone() {
    addPort "$md_id" "marathon" "Aleph One Engine - Marathon" "'$md_inst/bin/alephone' '$romdir/ports/$md_id/Marathon/'"
    addPort "$md_id" "marathon2" "Aleph One Engine - Marathon 2" "'$md_inst/bin/alephone' '$romdir/ports/$md_id/Marathon 2/'"
    addPort "$md_id" "marathoninfinity" "Aleph One Engine - Marathon Infinity" "'$md_inst/bin/alephone' '$romdir/ports/$md_id/Marathon Infinity/'"

    mkRomDir "ports/$md_id"

    moveConfigDir "$home/.alephone" "$md_conf_root/alephone"
    # fix for wrong config location
    if [[ -d "/alephone" ]]; then
        cp -R /alephone "$md_conf_root/"
        rm -rf /alephone
        chown $user:$user "$md_conf_root/alephone"
    fi

    [[ "$md_mode" == "install" ]] && _game_data_alephone
}
