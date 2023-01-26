#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-superflappybirds"
rp_module_desc="Super Flappy Birds Libretro Core"
rp_module_help="https://github.com/IgniparousTempest/libretro-superflappybirds/wiki"
rp_module_licence="GPL3 https://raw.githubusercontent.com/IgniparousTempest/libretro-superflappybirds/master/LICENSE"
rp_module_repo="git https://github.com/IgniparousTempest/libretro-superflappybirds master"
rp_module_section="exp"

function depends_lr-superflappybirds() {
    local depends=(
        'cmake'
        'gcc11'
        'ninja'
    )
    getDepends "${depends[@]}"
}

function sources_lr-superflappybirds() {
    gitPullOrClone
}

function build_lr-superflappybirds() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_C_COMPILER="gcc-11" \
        -DCMAKE_CXX_COMPILER="g++-11" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/superflappybirds_libretro.so"
}

function install_lr-superflappybirds() {
    md_ret_files=(
        'build/superflappybirds_libretro.so'
        'resources'
    )
}

function configure_lr-superflappybirds() {
    local portname
    portname="superflappybirds"

    [[ "${md_mode}" == "install" ]] && mkUserDir "${biosdir}/${portname}"

    setConfigRoot "ports"

    defaultRAConfig "superflappybirds" "system_directory" "${biosdir}/${portname}"

    addPort "${md_id}" "${portname}" "Super Flappy Birds" "${md_inst}/${portname}_libretro.so"    
}
