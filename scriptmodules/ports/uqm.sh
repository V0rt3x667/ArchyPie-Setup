#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="uqm"
rp_module_desc="The Ur-Quan Masters - Star Control 2 Port"
rp_module_licence="GPL2 https://sourceforce.net/p/sc2/uqm/ci/master/tree/sc2/COPYING?format=raw"
rp_module_repo="file https://sourceforge.net/projects/sc2/files/UQM/0.8/uqm-0.8.0-src.tgz"
rp_module_section="opt"

function depends_uqm() {
    local depends=(
        'imagemagick'
        'libglvnd'
        'libmikmod' 
        'libogg'
        'libvorbis' 
        'openal'
        'sdl2_image'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_uqm() {
    downloadAndExtract "$md_repo_url" "$md_build" --strip-components 1
    local ver="0.8.0"
    local url="https://sourceforge.net/projects/sc2/files/UQM/0.8"
    local file=(
        uqm-$ver-content.uqm
        uqm-$ver-voice.uqm
        uqm-$ver-3domusic.uqm
    )
    for f in "${file[@]}"; do
        if [[ $f == uqm-$ver-content.uqm ]]; then
            curl --create-dirs -sSL "$url/$f" --output "$md_build/content/packages/$f"
        else 
            curl --create-dirs -sSL "$url/$f" --output "$md_build/content/addons/$f"
        fi
    done
    chmod -R 755 "$md_build/content"
}

function build_uqm() {
    ./build.sh uqm clean
    echo "\n" | CHOICE_debug_VALUE="nodebug" INPUT_install_prefix_VALUE="$md_inst" ./build.sh uqm config
    ./build.sh uqm
    md_ret_require="$md_build/uqm"
}

function install_uqm() {
    ./build.sh uqm install
}

function configure_uqm() {
    addPort "$md_id" "uqm" "Ur-quan Masters" "$md_inst/bin/uqm -f"

    [[ "$md_mode" == "remove" ]] && return

    moveConfigDir "$home/.uqm" "$md_conf_root/uqm"
}