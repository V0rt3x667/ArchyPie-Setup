#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lincity-ng"
rp_module_desc="LinCity NG: A City Simulation Game"
rp_module_licence="GPL2 https://raw.githubusercontent.com/lincity-ng/lincity-ng/master/COPYING"
rp_module_repo="git https://github.com/lincity-ng/lincity-ng :_get_branch_lincity-ng"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_lincity-ng() {
    download "https://api.github.com/repos/lincity-ng/lincity-ng/releases" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_lincity-ng() {
    local depends=(
        'clang'
        'cmake'
        'icu'
        'libxml2'
        'libxslt'
        'lld'
        'ninja'
        'physfs'
        'sdl2_gfx'
        'sdl2_image'
        'sdl2_mixer'
        'sdl2_ttf'
        'sdl2'
        'xz'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_lincity-ng() {
    gitPullOrClone

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"
}

function build_lincity-ng() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/bin/${md_id}"
}

function install_lincity-ng() {
    ninja -C build install/strip
}

function configure_lincity-ng() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addPort "${md_id}" "${md_id}" "LinCity-NG" "${md_inst}/bin/${md_id} -g -f"
}
