#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="advmame"
rp_module_desc="AdvanceMAME: Arcade Machine Emulator (MAME 0.106)"
rp_module_help="ROM Extension: .zip\n\nCopy AdvanceMAME ROMs To Either: ${romdir}/mame-advmame\n\n${romdir}/arcade"
rp_module_licence="GPL2 https://raw.githubusercontent.com/amadvance/advancemame/master/COPYING"
rp_module_repo="git https://github.com/amadvance/advancemame master"
rp_module_section="opt"
rp_module_flags=""

function depends_advmame() {
    local depends=('sdl2')
    if isPlatform "rpi"; then
        depends+=('raspberrypi-firmware')
    fi
    getDepends "${depends[@]}"
}

function sources_advmame() {
    gitPullOrClone

    applyPatch "${md_data}/01_set_default_config_path.patch"
}

function build_advmame() {
    local params=(
        '--disable-oss'
        '--disable-sdl'
        '--disable-vc'
        '--enable-sdl2'
    )

    ./autogen.sh
    ./configure --prefix="${md_inst}" "${params[@]}"
    make clean
    make
    md_ret_require="${md_build}/${md_id}"
}

function install_advmame() {
    make install
}

function configure_advmame() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/mame-${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'artwork'
            'diff'
            'hi'
            'inp'
            'memcard'
            'nvram'
            'sample'
            'snap'
            'sta'
        )
        mkRomDir "arcade"
        mkRomDir "arcade/${md_id}"
        mkRomDir "mame-${md_id}"
        for dir in "${dirs[@]}"; do
            mkRomDir "mame-${md_id}/$dir"
            ln -sf "${romdir}/mame-${md_id}/${dir}" "${romdir}/arcade/${md_id}"
        done

        local config

        config="$(mktemp)"
        iniConfig ' ' '' "${config}"

        iniSet "dir_artwork" "${romdir}/mame-${md_id}/artwork"
        iniSet "dir_diff" "${romdir}/mame-${md_id}/diff"
        iniSet "dir_hi" "${romdir}/mame-${md_id}/hi"
        iniSet "dir_image" "${romdir}/mame-${md_id}"
        iniSet "dir_inp" "${romdir}/mame-${md_id}/inp"
        iniSet "dir_memcard" "${romdir}/mame-${md_id}/memcard"
        iniSet "dir_nvram" "${romdir}/mame-${md_id}/nvram"
        iniSet "dir_rom" "${romdir}/mame-${md_id}:${romdir}/arcade"
        iniSet "dir_sample" "${romdir}/mame-${md_id}/samples"
        iniSet "dir_snap" "${romdir}/mame-${md_id}/snap"
        iniSet "dir_sta" "${romdir}/mame-${md_id}/nvram"

        iniSet "device_keyboard" "sdl"
        iniSet "device_video_output" "overlay"
        iniSet "device_video" "sdl"

        iniSet "display_aspectx" 16
        iniSet "display_aspecty" 9
        iniSet "display_magnify" "1"

        iniSet "misc_quiet" "yes"
        # Disable Threading To Prevent "crash-on-exit"
        iniSet "misc_smp" "no"

        iniSet "sound_samplerate" "44100"

        copyDefaultConfig "${config}" "${md_conf_root}/mame-${md_id}/${md_id}.rc"
        rm "${config}"
    fi

    addEmulator 1 "${md_id}" "arcade" "${md_inst}/bin/${md_id} %BASENAME%"
    addEmulator 1 "${md_id}" "mame-${md_id}" "${md_inst}/bin/${md_id} %BASENAME%"

    addSystem "arcade"
    addSystem "mame-${md_id}"
}
