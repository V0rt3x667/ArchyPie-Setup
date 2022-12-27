#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="uqm"
rp_module_desc="The Ur-Quan Masters: Star Control 2 Port"
rp_module_licence="GPL2 https://sourceforce.net/p/sc2/uqm/ci/master/tree/sc2/COPYING?format=raw"
rp_module_repo="file https://sourceforge.net/projects/sc2/files/UQM/0.8/uqm-0.8.0-src.tgz"
rp_module_section="opt"

function depends_uqm() {
    local depends=(
        'imagemagick'
        'libmikmod'
        'libogg'
        'libvorbis'
        'sdl2_image'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_uqm() {
    downloadAndExtract "${md_repo_url}" "${md_build}" --strip-components 1
    local ver="0.8.0"
    local url="https://sourceforge.net/projects/sc2/files/UQM/0.8"
    local files=(
        "uqm-${ver}-content.uqm"
        "uqm-${ver}-voice.uqm"
        "uqm-${ver}-3domusic.uqm"
    )
    for file in "${files[@]}"; do
        if [[ "${file}" == "uqm-${ver}-content.uqm" ]]; then
            curl --create-dirs -sSL "${url}/${file}" --output "${md_build}/content/packages/${file}"
        else
            curl --create-dirs -sSL "${url}/${file}" --output "${md_build}/content/addons/${file}"
        fi
    done
    chmod -R 755 "${md_build}/content"

    # Set Default Config Path(s)
    sed -e "s|#define USERDIR \"~/.uqm/\"|#define USERDIR \"~/ArchyPie/configs/${md_id}/\"|g" -i "${md_build}/src/config_unix.h.in"
}

function build_uqm() {
    ./build.sh uqm clean

    local strings=(
        CHOICE_debug_VALUE='nodebug'
        CHOICE_graphics_VALUE='sdl2'
        CHOICE_sound_VALUE='mixsdl'
        CHOICE_mikmod_VALUE='internal'
        CHOICE_ovcodec_VALUE='standard'
        CHOICE_netplay_VALUE='full'
        CHOICE_joystick_VALUE='enabled'
        CHOICE_ioformat_VALUE='stdio_zip'
        CHOICE_threadlib_VALUE='sdl'
        INPUT_install_prefix_VALUE="${md_inst}"
        INPUT_install_bindir_VALUE="${md_inst}/bin"
        INPUT_install_libdir_VALUE="${md_inst}/lib"
        INPUT_install_sharedir_VALUE="${md_inst}/share"
    )
    for string in "${strings[@]}"; do
        printf "%s\n" "${string}" >> "${md_build}/config.state"
    done

    ./build.sh uqm reprocess_config
    ./build.sh uqm
    md_ret_require="${md_build}/${md_id}"
}

function install_uqm() {
    ./build.sh uqm install
}

function configure_uqm() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addPort "${md_id}" "${md_id}" "The Ur-Quan Masters" "${md_inst}/bin/${md_id} -f"
}
