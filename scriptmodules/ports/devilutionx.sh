#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="devilutionx"
rp_module_desc="DevilutionX - Diablo & Hellfire Port"
rp_module_licence="TU https://raw.githubusercontent.com/diasurgical/devilutionX/master/LICENSE"
rp_module_repo="git https://github.com/diasurgical/devilutionX.git :_get_branch_devilutionx"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_devilutionx() {
    download https://api.github.com/repos/diasurgical/devilutionX/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_devilutionx() {
    local depends=(
        'clang'
        'cmake'
        'fmt'
        'gettext'
        'libpng'
        'libsodium'
        'ninja'
        'sdl2'
        'sdl2_mixer'
        'sdl2_ttf'
    )
    getDepends "${depends[@]}"
}

function sources_devilutionx() {
    gitPullOrClone
}

function build_devilutionx() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/devilutionx"
}

function install_devilutionx() {
    cd build
    ninja install/strip
}

function configure_devilutionx() {
    mkRomDir "ports/diablo"

    moveConfigDir "$home/.local/share/diasurgical/devilution" "$md_conf_root/diablo"

    addPort "$md_id" "diablo" "diablo" "$md_inst/bin/devilutionx --data-dir $romdir/ports/diablo --save-dir $romdir/ports/diablo --ttf-dir $md_inst/emulators/devilutionx/share"
}
