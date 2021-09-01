#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="abuse"
rp_module_desc="Abuse - Abuse SDL Port"
rp_module_licence="NONCOM https://raw.githubusercontent.com/Xenoveritas/abuse/master/COPYING"
rp_module_repo="git https://github.com/Xenoveritas/abuse.git :_get_branch_abuse"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_abuse() {
    download https://api.github.com/repos/Xenoveritas/abuse/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_abuse() {
    local depends=(
        'cmake'     
        'sdl2_ttf'
    )
    getDepends "${depends[@]}"
}

function sources_abuse() {
    gitPullOrClone
    sed -e "s|ASSETDIR \"share/games/abuse\"|ASSETDIR "$md_inst"|g" -i "$md_build/CMakeLists.txt"
    downloadAndExtract http://abuse.zoy.org/raw-attachment/wiki/download/abuse-data-2.00.tar.gz "$md_build/data" music register sfx
}

function build_abuse() {
    mkdir build
    cd build
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -Wno-dev
    make clean
    make
    md_ret_require="$md_build/build/src/abuse"
}

function install_abuse() {
    md_ret_files=(        
        'build/src/abuse'
        'build/src/abuse-tool'
        'data/abuse.lsp'
        'data/edit.lsp'
        'data/hardness.lsp'
        'data/defaults.prp'
        'data/addon'
        'data/art'
        'data/levels'
        'data/lisp'
        'data/netlevel'
        'data/register'
        'data/music'
        'data/sfx'
    )
}

function configure_abuse() {
    moveConfigDir "$home/.abuse" "$md_conf_root/abuse"

    if isPlatform gl || isPlatform gles; then
        addPort "$md_id" "abuse" "Abuse" "$md_inst/abuse -datadir $md_inst -fullscreen -gl -antialias"
    else
        addPort "$md_id" "abuse" "Abuse" "$md_inst/abuse -datadir $md_inst -fullscreen"
    fi
}
