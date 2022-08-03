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
        'ninja'
        'sdl2'
        'sdl2_ttf'
    )
    getDepends "${depends[@]}"
}

function sources_abuse() {
    gitPullOrClone

    applyPatch "$md_data/01_set_default_config_path.patch"

    downloadAndExtract "$__arpie_url/Abuse-Data/abuse_assets.tar.xz" "$md_build/data" music register sfx

    sed -e "s|ASSETDIR \"share/games/abuse\"|ASSETDIR "data"|g" -i "$md_build/CMakeLists.txt"
}

function build_abuse() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DSDL2_MIXER_INCLUDE_DIR="/usr/include/SDL2" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/src/abuse"
}

function install_abuse() {
    ninja -C build install/strip
}

function configure_abuse() {
    if isPlatform gl || isPlatform gles; then
        addPort "$md_id" "abuse" "Abuse" "$md_inst/bin/abuse -datadir $md_inst/data -fullscreen -gl"
    else
        addPort "$md_id" "abuse" "Abuse" "$md_inst/bin/abuse -datadir $md_inst/data -fullscreen"
    fi

    mkUserDir "$arpiedir/ports"
    mkUserDir "$arpiedir/ports/$md_id"

    moveConfigDir "$arpiedir/ports/$md_id" "$md_conf_root/$md_id"
}
