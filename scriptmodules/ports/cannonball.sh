#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="cannonball"
rp_module_desc="Cannonball: An Enhanced OutRun Engine"
rp_module_help="Unzip the OutRun Revision B ROM Set from MAME (outrun.zip) to ${romdir}/ports/cannonball and rename ROM epr-10381a.132 to epr-10381b.132"
rp_module_licence="NONCOM https://raw.githubusercontent.com/djyt/cannonball/master/docs/license.txt"
rp_module_repo="git https://github.com/djyt/cannonball master"
rp_module_section="opt"

function depends_cannonball() {
    local depends=(
        'boost'
        'cmake'
        'ninja'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_cannonball() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|<rompath>roms/</rompath>|<rompath>${romdir}/ports/${md_id}/</rompath>|g" -i "${md_build}/res/config.xml"
    sed -e "s|<savepath>./</savepath>|<savepath>${romdir}/ports/${md_id}/hiscores/${md_id}/</savepath>|g" -i "${md_build}/res/config.xml"

    # Set Fullscreen By Default
    sed -e "s|<mode>0</mode>|<mode>1</mode>|g" -i "${md_build}/res/config.xml"
}

function build_cannonball() {
    local target
    if isPlatform "rpi4"; then
        target="pi4-opengles.cmake"
    else
        target="linux.cmake"
    fi

    cmake . \
        -Scmake \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DTARGET="${target}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_cannonball() {
    md_ret_files=(
        'build/cannonball'
        'build/config.xml'
        'build/res'
        'roms/roms.txt'
    )
}

function configure_cannonball() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ports/${md_id}"
        mkRomDir "ports/${md_id}/hiscores"
        mkRomDir "ports/${md_id}/hiscores/${md_id}"
        mkUserDir "${md_conf_root}/${md_id}"

        copyDefaultConfig "${md_inst}/config.xml" "${md_conf_root}/${md_id}/config.xml"
        copyDefaultConfig "${md_inst}/roms.txt" "${romdir}/ports/${md_id}/roms.txt"
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addPort "${md_id}" "${md_id}" "Cannonball: OutRun Engine" "pushd ${md_inst}; ${md_inst}/${md_id} -cfgfile ${arpdir}/${md_id}/config.xml; popd"
}
