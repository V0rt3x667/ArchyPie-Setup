#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-potator"
rp_module_desc="Watara Supervision (QuickShot Supervision) Libretro Core"
rp_module_help="ROM Extensions: .7z .sv .zip\n\nCopy Supervision Games To: ${romdir}/supervision"
rp_module_licence="UNL https://raw.githubusercontent.com/libretro/potator/master/LICENSE"
rp_module_repo="git https://github.com/libretro/potator master"
rp_module_section="exp"

function depends_lr-potator() {
    local depends=(
        'glibc'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_lr-potator() {
    gitPullOrClone
}

function build_lr-potator() {
    make -C platform/libretro clean
    make -C platform/libretro
    md_ret_require="${md_build}/platform/libretro/potator_libretro.so"
}

function install_lr-potator() {
    md_ret_files=('platform/libretro/potator_libretro.so')
}

function configure_lr-potator() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "supervision"
        defaultRAConfig "supervision"
    fi

    addEmulator 1 "${md_id}" "supervision" "${md_inst}/potator_libretro.so"

    addSystem "supervision"
}
