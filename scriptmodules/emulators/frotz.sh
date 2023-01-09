#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="frotz"
rp_module_desc="Frotz - Interpreter for Infocom & Z-Machine Games"
rp_module_help="ROM Extensions: .dat .zip .z1 .z2 .z3 .z4 .z5 .z6 .z7 .z8\n\nCopy your Infocom games to $romdir/zmachine"
rp_module_licence="GPL2 https://gitlab.com/DavidGriffith/frotz/raw/master/COPYING"
rp_module_section="opt"
rp_module_repo="git https://gitlab.com/DavidGriffith/frotz.git :_get_branch_frotz"
rp_module_flags=""

function _get_branch_frotz() {
    download https://gitlab.com/api/v4/projects/DavidGriffith%2Ffrotz/releases - | grep -m 1 tag_name | cut -d\" -f8
}

function depends_frotz() {
    local depends=(
        'freetype2'
        'libao'
        'libjpeg-turbo'
        'libmodplug'
        'libpng'
        'libsamplerate'
        'libsndfile'
        'libvorbis'
        'sdl2'
        'sdl2_mixer'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_frotz() {
    gitPullOrClone
}

function build_frotz() {
    make PREFIX="$md_inst" SYSCONFDIR="$HOME/.config/frotz" sdl
}

function install_frotz() {
     make PREFIX="$md_inst" install_sdl
}

function game_data_frotz() {
    local dest="$romdir/zmachine"
    if [[ ! -f "$dest/zork1.dat" ]]; then
        mkUserDir "$dest"
        local temp="$(mktemp -d)"
        local file
        for file in zork1 zork2 zork3; do
            downloadAndExtract "$__archive_url/${file}.zip" "$temp" -L
            cp "$temp/data/${file}.dat" "$dest"
            rm -rf "$temp"
        done
        rm -rf "$temp"
        chown -R "${user}:${user}" "$romdir/zmachine"
    fi
}

function configure_frotz() {
    mkRomDir "zmachine"

    # CON: to stop runcommand from redirecting stdout to log
    addEmulator 1 "$md_id" "zmachine" "CON:pushd $romdir/zmachine; $md_inst/bin/sfrotz -F %ROM%; popd"
    addSystem "zmachine"

    [[ "$md_mode" == "install" ]] && game_data_frotz
}
