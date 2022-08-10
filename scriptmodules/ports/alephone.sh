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
        'boost-libs'
        'ffmpeg4.4'
        'glu'
        'libmad'
        'libvorbis'
        'sdl2'
        'sdl2_image'
        'sdl2_net'
        'sdl2_ttf'
        'zziplib'
    )
    getDepends "${depends[@]}"
}

function sources_alephone() {
    gitPullOrClone

    applyPatch "$md_data/01_set_default_config_path.patch"
}

function build_alephone() {
    params=(--prefix="$md_inst")
    isPlatform "arm" && params+=(--with-boost-libdir=/usr/lib/arm-linux-gnueabihf)
    ./autogen.sh
    PKG_CONFIG_PATH="/usr/lib/ffmpeg4.4/pkgconfig" ./configure "${params[@]}"
    make clean
    make
    md_ret_require="$md_build/Source_Files/alephone"
}

function install_alephone() {
    make install
}

function _game_data_alephone() {
  local version="$(_get_branch_alephone)"
  local release_url="https://github.com/Aleph-One-Marathon/alephone/releases/download/$version"

    if [[ ! -f "$romdir/ports/$md_id/Marathon/Shapes.shps" ]]; then
        downloadAndExtract "$release_url/Marathon-${version/release-/}-Data.zip" "$romdir/ports/$md_id"
    fi

    if [[ ! -f "$romdir/ports/$md_id/Marathon 2/Shapes.shpA" ]]; then
        downloadAndExtract "$release_url/Marathon2-${version/release-/}-Data.zip" "$romdir/ports/$md_id"
    fi

    if [[ ! -f "$romdir/ports/$md_id/Marathon Infinity/Shapes.shpA" ]]; then
        downloadAndExtract "$release_url/MarathonInfinity-${version/release-/}-Data.zip" "$romdir/ports/$md_id"
    fi

    chown -R "$user:$user" "$romdir/ports/$md_id"
}

function configure_alephone() {
    if [[ "$md_mode" == "install" ]]; then
        mkRomDir "ports/$md_id" && _game_data_alephone
    fi

    addPort "$md_id" "alephone" "Aleph One Engine: Marathon" "$md_inst/bin/alephone %ROM%" "$romdir/ports/$md_id/Marathon/"
    addPort "$md_id" "alephone" "Aleph One Engine: Marathon 2: Durandal" "$md_inst/bin/alephone %ROM%" "$romdir/ports/$md_id/Marathon 2/"
    addPort "$md_id" "alephone" "Aleph One Engine: Marathon Infinity" "$md_inst/bin/alephone %ROM%" "$romdir/ports/$md_id/Marathon Infinity/"

    moveConfigDir "$arpiedir/ports/$md_id" "$md_conf_root/$md_id/"
}
