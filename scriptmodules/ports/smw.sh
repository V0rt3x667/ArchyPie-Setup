#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="smw"
rp_module_desc="Super Mario War: Fan-made Multiplayer Super Mario Bros. Style Deathmatch Game"
rp_module_licence="NONCOM"
rp_module_repo="git https://github.com/mmatyas/supermariowar master"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_smw() {
    local depends=(
        'cmake'
        'enet'
        'ninja'
        'sdl2_image'
        'sdl2_mixer'
        'sdl2'
        'yaml-cpp'
    )
    getDepends "${depends[@]}"
}

function sources_smw() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|std::string result(\".smw/\");|std::string result(\"ArchyPie/configs/${md_id}/\");|g" -i "${md_build}/src/common/path.cpp"
}

function build_smw() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DBUILD_STATIC_LIBS="OFF" \
        -DSMW_BINDIR="${md_inst}" \
        -DSMW_DATADIR="${md_inst}/data"
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/Binaries/Release/${md_id}"
}

function install_smw() {
    ninja -C build install/strip
    chmod a+x "${md_inst}"/{smw,smw-leveledit,smw-worldedit}
}

function configure_smw() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}"

    addPort "${md_id}" "${md_id}" "Super Mario War" "${md_inst}/${md_id}"
}
