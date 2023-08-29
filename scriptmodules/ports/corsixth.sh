#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="corsixth"
rp_module_desc="CorsixTH: Theme Hospital Port"
rp_module_licence="GPL2 https://raw.githubusercontent.com/CorsixTH/CorsixTH/master/LICENSE.txt"
rp_module_repo="git https://github.com/CorsixTH/CorsixTH :_get_branch_corsixth"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_corsixth() {
    download "https://api.github.com/repos/corsixth/corsixth/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_corsixth() {
    local depends=(
        'cmake'
        'doxygen'
        'ffmpeg'
        'lua-filesystem'
        'lua-lpeg'
        'lua'
        'ninja'
        'sdl2_mixer'
        'sdl2'
        'timidity++'
    )
    getDepends "${depends[@]}"
}

function sources_corsixth() {
    gitPullOrClone

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"

    # Set Fullscreen By Default
    sed -e "s|fullscreen = false,|fullscreen = true,|g" -i "${md_build}/CorsixTH/Lua/config_finder.lua"

    # Set Theme Hospital Install Location
    sed -e "s|theme_hospital_install = \[\[X:\\\ThemeHospital\\\hospital\]\],|theme_hospital_install = \[\[${romdir}/ports/themehospital\]\],|g" -i "${md_build}/CorsixTH/Lua/config_finder.lua"
}

function build_corsixth() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/CorsixTH/corsix-th"
}

function install_corsixth() {
    ninja -C build install/strip
}

function configure_corsixth() {
    local portname
    portname="themehospital"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}"

    [[ "${md_mode}" == "install" ]] && mkRomDir "ports/${portname}"

    addPort "${md_id}" "${portname}" "Theme Hospital" "${md_inst}/bin/corsix-th"
}
