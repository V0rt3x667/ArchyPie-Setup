#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="cannonball"
rp_module_desc="Cannonball - An Enhanced OutRun Engine"
rp_module_help="You need to unzip your OutRun set B from latest MAME (outrun.zip) to $romdir/ports/cannonball. They should match the file names listed in the roms.txt file found in the roms folder. You will also need to rename the epr-10381a.132 file to epr-10381b.132 before it will work."
rp_module_licence="NONCOM https://raw.githubusercontent.com/djyt/cannonball/master/docs/license.txt"
rp_module_repo="git https://github.com/djyt/cannonball.git master"
rp_module_section="opt"

function depends_cannonball() {
    local depends=(
        'boost'
        'cmake'
        'ninja'
        'sdl2'
    )
    isPlatform "rpi" && depends+=('raspberrypi-firmware')
    isPlatform "mesa" && depends+=('mesa')

    getDepends "${depends[@]}"
}

function sources_cannonball() {
    gitPullOrClone

    applyPatch "$md_data/01_set_config_&_rom_paths.patch"
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
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DTARGET="$target" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/cannonball"
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
    if [[ "$md_mode" == "install" ]]; then
        mkRomDir "ports/$md_id"
        mkRomDir "ports/$md_id/hiscores/$md_id"
    fi

    addPort "$md_id" "cannonball" "Cannonball: OutRun Engine" "pushd $md_inst; $md_inst/cannonball; popd"

    moveConfigDir "$arpiedir/ports/$md_id" "$md_conf_root/$md_id/"

    if [[ "$md_mode" == "install" ]]; then
        copyDefaultConfig "$md_inst/config.xml" "$md_conf_root/$md_id/config.xml"
        copyDefaultConfig "$md_inst/roms.txt" "$romdir/ports/$md_id/roms.txt"
    fi
}
