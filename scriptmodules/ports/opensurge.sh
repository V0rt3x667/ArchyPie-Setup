#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="opensurge"
rp_module_desc="Open Surge: A Fun 2D Retro Platformer & Game Engine"
rp_module_licence="GPL3 https://raw.githubusercontent.com/alemart/opensurge/master/LICENSE"
rp_module_repo="git https://github.com/alemart/opensurge :_get_branch_opensurge"
rp_module_section="opt"
rp_module_flags="!wayland"

function _get_branch_opensurge() {
    download "https://api.github.com/repos/alemart/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function _get_branch_surgescript() {
    download "https://api.github.com/repos/alemart/surgescript/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_opensurge() {
    local depends=(
        'allegro'
        'cmake'
        'ninja'
    )
    getDepends "${depends[@]}"
}

function sources_opensurge() {
    gitPullOrClone
    _sources_surgescript

    # Set Default Config Path(s)
    sed -e "s|path = \"/.config/\"|path = \"/ArchyPie/configs/${md_id}/\"|g" -i "${md_build}/src/core/assetfs.c"
    sed -e "s|path = \"/.local/share/\"|path = \"/ArchyPie/configs/${md_id}/\"|g" -i "${md_build}/src/core/assetfs.c"
    sed -e "s|path = \"/.cache/\"|path = \"/ArchyPie/configs/${md_id}/\"|g" -i "${md_build}/src/core/assetfs.c"
}

function _sources_surgescript() {
    local tag
    tag="$(_get_branch_surgescript)"

    gitPullOrClone "${md_build}/surgescript" "https://github.com/alemart/surgescript" "${tag}"
}

function _build_surgescript() {
    cmake . \
        -Ssurgescript \
        -Bsurgescript \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DWANT_SHARED="ON" \
        -DWANT_STATIC="OFF" \
        -Wno-dev
    ninja -C surgescript clean
    ninja -C surgescript
    md_ret_require="${md_build}/surgescript/surgescript"
}

function build_opensurge() {
    _build_surgescript

    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -Wl,-rpath='${md_inst}/lib'" \
        -DGAME_BINDIR="${md_inst}/bin" \
        -DGAME_DATADIR="${md_inst}/data" \
        -DDESKTOP_INSTALL="OFF" \
        -DSURGESCRIPT_INCLUDE_PATH="${md_build}/surgescript/src" \
        -DSURGESCRIPT_LIBRARY_PATH="${md_build}/surgescript" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/${md_id}"
}

function install_opensurge() {
    ninja -C build install/strip

    mkdir "${md_inst}/lib"
    cp -Pv "${md_build}/surgescript"/*.so* "${md_inst}/lib"
    cp -Pv "${md_build}/surgescript/surgescript" "${md_inst}/bin"
}

function configure_opensurge() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}"

    addPort "${md_id}" "${md_id}" "Open Surge" "${md_inst}/bin/${md_id} --fullscreen"
}
