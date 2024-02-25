#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="openjazz"
rp_module_desc="OpenJazz: Open-Source Version Of The Classic Jazz Jackrabbit Games"
rp_module_licence="GPL2 https://raw.githubusercontent.com/AlisterT/openjazz/master/COPYING"
rp_module_help="For Registered Version, Replace The Shareware Files By Adding The Full Version Game Files To: ${romdir}/ports/jazz"
rp_module_repo="git https://github.com/AlisterT/openjazz :_get_branch_openjazz"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_openjazz() {
    download "https://api.github.com/repos/AlisterT/openjazz/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_openjazz() {
    local depends=(
        'asciidoctor'
        'astyle'
        'clang'
        'cmake'
        'lld'
        'ninja'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_openjazz() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed "s|\"/.config\"|\"/ArchyPie/configs\"|g" -i "${md_build}/src/platforms/xdg.cpp"
    sed "s|\"/.local/share\"|\"/ArchyPie/configs\"|g" -i "${md_build}/src/platforms/xdg.cpp"
}

function build_openjazz() {
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
    md_ret_require="${md_build}/build/OpenJazz"
}

function install_openjazz() {
    ninja -C build install/strip
}

function _game_data_openjazz() {
    local portname
    portname="openjazz"

    if [[ ! -f "${romdir}/ports/${portname}/JAZZ.EXE" ]]; then
        downloadAndExtract "https://image.dosgamesarchive.com/games/jazz.zip" "${romdir}/ports/${portname}"
        chown -R "${user}:${user}" "${romdir}/ports/${portname}"
    fi
}

function configure_openjazz() {
    local portname
    portname="openjazz"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ports/${portname}"
        _game_data_openjazz
    fi

    addPort "${md_id}" "${portname}" "Jazz Jackrabbit" "pushd ${md_conf_root}/${md_id}; ${md_inst}/OpenJazz -f DATAPATH ${romdir}/ports/${portname}; popd"
}
