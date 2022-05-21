#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="opensurge"
rp_module_desc="Open Surge - A Fun 2D Retro Platformer & Game Engine"
rp_module_licence="GPL3 https://raw.githubusercontent.com/alemart/opensurge/master/LICENSE"
rp_module_repo="git https://github.com/alemart/opensurge.git :_get_branch_opensurge"
rp_module_section="opt"

function _get_branch_opensurge() {
    download https://api.github.com/repos/alemart/opensurge/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function _get_branch_surgescript() {
    download https://api.github.com/repos/alemart/surgescript/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_opensurge() {
    local depends=(
        'allegro'
        'cmake'
        'ninja'
    )
    getDepends "${depends[@]}"
}

#function _sources_surgescript() {
#    downloadAndExtract "https://github.com/alemart/surgescript/archive/refs/tags/$(_get_branch_surgescript).tar.gz" "$md_build/surgescript" --strip-components 1
#}

function sources_opensurge() {
    gitPullOrClone
    downloadAndExtract "https://github.com/alemart/surgescript/archive/refs/tags/$(_get_branch_surgescript).tar.gz" "$md_build/surgescript" --strip-components 1
    #_sources_surgescript
}

function _build_surgescript() {
    cmake . \
        -Ssurgescript \
        -Bsurgescript \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DWANT_SHARED=ON \
        -DWANT_STATIC=OFF
    ninja -C surgescript clean
    ninja -C surgescript
    md_ret_require="$md_build/surgescript/surgescript"
}

function build_opensurge() {
    _build_surgescript

    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -Wl,-rpath='$md_inst/lib'" \
        -DGAME_BINDIR="$md_inst/bin" \
        -DGAME_DATADIR="$md_inst/data" \
        -DDESKTOP_INSTALL="OFF" \
        -DSURGESCRIPT_INCLUDE_PATH="$md_build/surgescript/src" \
        -DSURGESCRIPT_LIBRARY_PATH="$md_build/surgescript" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/opensurge"
}

function install_opensurge() {
    ninja -C build install/strip

    install -Dm644 "$md_build/surgescript/libsurgescript.so.0.5.5" -t "$md_inst/lib"
    install -Dm644 "$md_build/surgescript/surgescript" -t "$md_inst/bin"
}

function configure_opensurge() {
    addPort "$md_id" "opensurge" "Open Surge" "$md_inst/bin/opensurge --fullscreen"

    moveConfigDir "$home/.config/opensurge2d" "$md_conf_root/opensurge"
}
