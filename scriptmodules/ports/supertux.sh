#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="supertux"
rp_module_desc="SuperTux - Classic 2D Jump'n'Run Sidescroller Game"
rp_module_licence="GPL3 https://raw.githubusercontent.com/SuperTux/supertux/master/LICENSE.txt"
rp_module_repo="git https://github.com/SuperTux/supertux.git :_get_branch_supertux"
rp_module_section="opt"
rp_module_flags="!mali"

function _get_branch_supertux() {
    download https://api.github.com/repos/SuperTux/supertux/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_supertux() {
    local depends=(
        'boost'
        'cmake'
        'glew'
        'libraqm'
        'libvorbis'
        'mesa'
        'openal'
        'optipng'
        'physfs'
        'sdl2_image'
    )
    getDepends "${depends[@]}"
}

function sources_supertux() {
    gitPullOrClone
    applyPatch "$md_data/01_fix_build.patch"
}

function build_supertux() {
    cmake . \
        -Bbuild \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DINSTALL_SUBDIR_BIN=bin \
        -DUSE_SYSTEM_PHYSFS=ON \
        -Wno-dev
    make -C build clean
    make -C build
    md_ret_require="$md_build/build/supertux2"
}

function install_supertux() {
    make -C build install/strip
}

function configure_supertux() {
    addPort "$md_id" "supertux" "SuperTux" "$md_inst/bin/supertux2 --fullscreen"

    moveConfigDir "$home/.local/share/supertux2" "$md_conf_root/supertux"
}
