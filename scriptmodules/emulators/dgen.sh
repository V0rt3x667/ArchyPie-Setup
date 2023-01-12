#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dgen"
rp_module_desc="DGEN: Sega Megadrive (Genesis) Emulator"
rp_module_help="ROM Extensions: .32x .iso .cue .smd .bin .gen .md .sg .zip\n\nCopy Sega Megadrive (Genesis) ROMs To: ${romdir}/megadrive\nSega 32X ROMs To: ${romdir}/sega32x\nSegaCD ROMs To: ${romdir}/segacd\nSega CD Requires BIOS Files (bios_CD_U.bin, bios_CD_E.bin, & bios_CD_J.bin) Copied To: ${biosdir}/segacd"
rp_module_licence="GPL2 https://sourceforge.net/p/dgen/dgen/ci/master/tree/COPYING"
rp_module_repo="file ${__archive_url}/dgen-sdl-1.33.tar.gz"
rp_module_section="opt"
rp_module_flags=""

function depends_dgen() {
    local depends=(
        'libarchive'
        'sdl12-compat'
    )
    getDepends "${depends[@]}"
}

function sources_dgen() {
    downloadAndExtract "${md_repo_url}" "${md_build}" --strip-components 1

    # Set Default Config Path(s)
    sed -e "s|#define DGEN_BASEDIR \".dgen\"|#define DGEN_BASEDIR \"ArchyPie/configs/dgen\"|g" -i "${md_build}/system.h"
}

function build_dgen() {
    # DGEN Contains Obsoleted ARM Assembler That GCC/AS Will Not Like For armv8 CPU Targets
    if isPlatform "armv8"; then
        CFLAGS="-O2 -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard" ./configure --prefix="${md_inst}"
    else
        ./configure --prefix="${md_inst}"
    fi
    make clean
    make
    md_ret_require="${md_build}/${md_id}"
}

function install_dgen() {
    make install
}

function configure_dgen() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/megadrive/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'megadrive'
            'sega32x'
            'segacd'
        )
        for dir in "${dirs[@]}"; do
            mkRomDir "${dir}"
        done

        local config
        config="$(mktemp)"

        iniConfig ' = ' '' "${config}"

        iniSet "joy_pad1_a" "joystick0-button0"
        iniSet "joy_pad1_b" "joystick0-button1"
        iniSet "joy_pad1_c" "joystick0-button2"
        iniSet "joy_pad1_x" "joystick0-button3"
        iniSet "joy_pad1_y" "joystick0-button4"
        iniSet "joy_pad1_z" "joystick0-button5"
        iniSet "joy_pad1_mode" "joystick0-button6"
        iniSet "joy_pad1_start" "joystick0-button7"

        iniSet "joy_pad2_a" "joystick1-button0"
        iniSet "joy_pad2_b" "joystick1-button1"
        iniSet "joy_pad2_c" "joystick1-button2"
        iniSet "joy_pad2_x" "joystick1-button3"
        iniSet "joy_pad2_y" "joystick1-button4"
        iniSet "joy_pad2_z" "joystick1-button5"
        iniSet "joy_pad2_mode" "joystick1-button6"
        iniSet "joy_pad2_start" "joystick1-button7"

        copyDefaultConfig "${config}" "${md_conf_root}/megadrive/${md_id}/dgenrc"
        rm "${config}"
    fi

    addEmulator 0 "${md_id}" "megadrive" "${md_inst}/bin/${md_id} -f -r ${md_conf_root}/megadrive/${md_id}/dgenrc %ROM%"
    addEmulator 0 "${md_id}" "sega32x" "${md_inst}/bin/${md_id} -f -r ${md_conf_root}/megadrive/${md_id}/dgenrc %ROM%"
    addEmulator 0 "${md_id}" "segacd" "${md_inst}/bin/${md_id} -f -r ${md_conf_root}/megadrive/${md_id}/dgenrc %ROM%"

    addSystem "megadrive"
    addSystem "sega32x"
    addSystem "segacd"
}
