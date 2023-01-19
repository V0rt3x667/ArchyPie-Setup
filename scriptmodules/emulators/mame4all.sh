#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="mame4all"
rp_module_desc="MAME4All-Pi: Arcade Machine Emulator (MAME 0.375b5)"
rp_module_help="ROM Extension: .zip\n\nCopy MAME4all-Pi ROMs To Either: ${romdir}/mame-mame4all\n\n${romdir}/arcade"
rp_module_licence="NONCOM https://raw.githubusercontent.com/RetroPie/mame4all-pi/master/readme.txt"
rp_module_repo="git https://github.com/RetroPie/mame4all-pi master"
rp_module_section="opt"
rp_module_flags=""
#rp_module_flags="!all rpi"

function depends_mame4all() {
    local depends=(
        'ffmpeg'
        'raspberrypi-firmware'
        'sdl12-compat'
    )
    getDepends "${depends[@]}"
}

function sources_mame4all() {
    gitPullOrClone
}

function build_mame4all() {
    make clean
    # 'drz80' Contains Obsoleted ARM Assembler That GCC/As Will Not Like For ARM8 CPU Targets
    if isPlatform "armv8"; then
        CFLAGS="-O2 -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard" make
    else
        make
    fi
    md_ret_require="${md_build}/${md_id}"
}

function install_mame4all() {
    md_ret_files=(
        'cheat.dat'
        'clrmame.dat'
        'folders'
        'hiscore.dat'
        'mame.cfg.template'
        'mame'
        'readme.txt'
        'skins'
    )
}

function configure_mame4all() {
    moveConfigFile "${md_inst}/mame.cfg" "${md_conf_root}/${system}/mame.cfg"

    if [[ "${md_mode}" == "install" ]]; then
        local system="mame-${md_id}"
        mkRomDir "arcade"
        mkRomDir "${system}"

        # Create MAME Directories
        local dirs=(
            'artwork'
            'cfg'
            'hi'
            'inp'
            'memcard'
            'nvram'
            'samples'
            'snap'
            'sta'
        )
        for dir in "${dirs[@]}"; do
            mkRomDir "${system}/${dir}"
        done

        # Create MAME Config File
        local config
        config="$(mktemp)"
        cp "mame.cfg.template" "${config}"

        iniConfig "=" "" "${config}"
        iniSet "artwork" "${romdir}/${system}/artwork"
        iniSet "rompath" "${romdir}/${system};${romdir}/arcade"
        iniSet "samplepath" "${romdir}/${system}/samples;${romdir}/arcade/samples"

        iniSet "cfg" "${romdir}/${system}/cfg"
        iniSet "hi" "${romdir}/${system}/hi"
        iniSet "inp" "${romdir}/${system}/inp"
        iniSet "memcard" "${romdir}/${system}/memcard"
        iniSet "nvram" "${romdir}/${system}/nvram"
        iniSet "snap" "${romdir}/${system}/snap"
        iniSet "sta" "${romdir}/${system}/sta"

        iniSet "samplerate" "44100"

        copyDefaultConfig "${config}" "${md_conf_root}/${system}/mame.cfg"
        rm "${config}"

        chown -R "${user}:${user}" "${md_conf_root}/${system}"
    fi

    addEmulator 0 "${md_id}" "arcade" "${md_inst}/mame %BASENAME%"
    addEmulator 1 "${md_id}" "${system}" "${md_inst}/mame %BASENAME%"

    addSystem "arcade"
    addSystem "${system}"
}
