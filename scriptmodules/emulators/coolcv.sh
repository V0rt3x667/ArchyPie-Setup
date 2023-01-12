#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="coolcv"
rp_module_desc="CoolCV: ColecoVision Emulator"
rp_module_help="ROM Extensions: .bin .col .rom .zip\n\nCopy ColecoVision ROMs To: ${romdir}/coleco"
rp_module_licence="PROP"
rp_module_repo="file ${__archive_url}/coolcv.tar.gz"
rp_module_section="opt"
rp_module_flags="!all rpi"

function depends_coolcv() {
    local depends=(
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function install_bin_coolcv() {
    downloadAndExtract "${md_repo_url}" "${md_inst}" --strip-components 1
}

function configure_coolcv() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "coleco"
    fi

    moveConfigFile "${home}/coolcv_mapping.txt" "${md_conf_root}/coleco/coolcv_mapping.txt"

    addEmulator 1 "${md_id}" "coleco" "${md_inst}/coolcv_pi %ROM%"

    addSystem "coleco"
}
