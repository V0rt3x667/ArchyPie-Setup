#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="taradino"
rp_module_desc="Taradino: Rise of the Triad Source Port"
rp_module_help="Copy Rise of the Triad Game Files To: ${romdir}/rott"
rp_module_licence="GPL2 https://raw.githubusercontent.com/fabiangreffrath/taradino/main/COPYING"
rp_module_repo="git https://github.com/fabiangreffrath/taradino main"
rp_module_section="exp"
rp_module_flags=""

function depends_taradino() {
    local depends=(
        'clang'
        'cmake'
        'lld'
        'ninja'
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_taradino() {
    gitPullOrClone

    applyPatch "${md_data}/01_set_default_config_path.patch"
}

function build_taradino() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_taradino() {
    md_ret_files=(
        'build/taradino'
        'doc'
    )
}

function configure_taradino() {
    local portname
    portname="rott"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"

    [[ "${md_mode}" == "install" ]] && mkRomDir "ports/${portname}"

    addPort "${md_id}" "${portname}" "Rise of the Triad: Dark War" "${md_inst}/${md_id}"
}
