#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="atari800"
rp_module_desc="Atari 800: Atari 400, 800, 600XL, 800XL, 130XE & 5200 Emulator"
rp_module_help="ROM Extensions: .a52 .atr .bas .bin .car .dcm .xex .xfd .xfd.gz\n\nCopy Atari800 Games To: ${romdir}/atari800\n\nCopy Atari 5200 ROMs To: ${romdir}/atari5200\n\nCopy Atari 800 & Atari 5200 BIOS Files (5200.ROM, ATARIBAS.ROM, ATARIOSB.ROM & ATARIXL.ROM) To: ${biosdir}\n\nOn First Launch Configure Atari800 To Scan The BIOS Folder For ROMs (F1 -> Emulator Configuration -> System ROM Settings)"
rp_module_licence="GPL2 https://raw.githubusercontent.com/atari800/atari800/master/COPYING"
rp_module_repo="git https://github.com/atari800/atari800.git :_get_branch_atari800"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_atari800() {
    download "https://api.github.com/repos/${md_id}/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_atari800() {
    local depends=(
        'libpng'
        'sdl2'
        'zlib'
    )
    isPlatform "rpi" && depends+=('raspberrypi-firmware')
    getDepends "${depends[@]}"
}

function sources_atari800() {
    gitPullOrClone
}

function build_atari800() {
    local params=()
    ./autogen.sh
    isPlatform "rpi" && params+=('--target=rpi')
    ./configure --prefix="${md_inst}" "${params[@]}"
    make clean
    make
    md_ret_require="${md_build}/src/${md_id}"
}

function install_atari800() {
    make -C src install
}

function configure_atari800() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "atari800"
        mkRomDir "atari5200"

        # Copy Launcher Script
        sed "s#EMULATOR#/bin/${md_id}#" "${md_data}/atari800.sh" >"${md_inst}/${md_id}.sh"
        chmod a+x "${md_inst}/${md_id}.sh"
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    local params=(
        "-config ${md_conf_root}/${md_id}/atari800.cfg"
        "-fullscreen"
        "-video-accel"
    )

    addEmulator 1 "${md_id}" "atari800" "${md_inst}/atari800.sh %ROM% ${params[*]}"
    addEmulator 1 "${md_id}-800" "atari800" "${md_inst}/atari800.sh %ROM% ${params[*]} -atari"
    addEmulator 1 "${md_id}-800xl" "atari800" "${md_inst}/atari800.sh %ROM% ${params[*]} -xl"
    addEmulator 1 "${md_id}-130xe" "atari800" "${md_inst}/atari800.sh %ROM% ${params[*]} -xe"
    addEmulator 1 "${md_id}-5200" "atari5200" "${md_inst}/atari800.sh %ROM% ${params[*]} -5200"

    addSystem "atari800"
    addSystem "atari5200"
}
