#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="pifba"
rp_module_desc="PiFBA: Final Burn Alpha Emulator (FB Alpha 0.2.96.71)"
rp_module_help="ROM Extension: .zip\n\nCopy FBA ROMs To One Of:\n${romdir}/fba\n${romdir}/neogeo\n${romdir}/arcade\n\nFor NeoGeo Copy BIOS File (neogeo.zip) To One Of:\n${romdir}/fba\n${romdir}/neogeo\n${romdir}/arcade"
rp_module_licence="GPL2 https://raw.githubusercontent.com/RetroPie/pifba/master/FBAcapex_src/COPYING"
rp_module_repo="git https://github.com/RetroPie/pifba master"
rp_module_section="opt"
rp_module_flags="!all rpi"

function depends_pifba() {
    local depends=(
        'ffmpeg'
        'raspberrypi-firmware'
        'sdl12-compat'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_pifba() {
    gitPullOrClone
}

function build_pifba() {
    mkdir ".obj"
    make clean
    make
    md_ret_require="${md_build}/fba2x"
}

function install_pifba() {
    mkdir -p "${md_inst}"/{roms,skin,preview}
    md_ret_files=(
        'capex.cfg.template'
        'fba_029671_clrmame_dat.zip'
        'fba2x.cfg.template'
        'fba2x'
        'FBACache_windows.zip'
        'rominfo.fba'
        'zipname.fba'
    )
}

function configure_pifba() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "arcade"
        mkRomDir "fba"
        mkRomDir "neogeo"

        mkUserDir "${md_conf_root}/fba"

        local configs=(
            'capex.cfg'
            'fba2x.cfg'
        )
        for config in "${configs[@]}"; do
            copyDefaultConfig "${config}.template" "${md_conf_root}/fba/${config}"
        done
    fi

    addEmulator 0 "${md_id}" "arcade" "${md_inst}/fba2x %ROM%"
    addEmulator 0 "${md_id}" "fba" "${md_inst}/fba2x %ROM%"
    addEmulator 0 "${md_id}" "neogeo" "${md_inst}/fba2x %ROM%"

    addSystem "arcade"
    addSystem "fba"
    addSystem "neogeo"
}
