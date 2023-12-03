#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-bsnes-mercury"
rp_module_desc="Nintendo SNES Libretro Core"
rp_module_help="ROM Extensions: .bml .sfc .smc .zip\n\nCopy SNES ROMs To: ${romdir}/snes"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/bsnes-mercury/master/LICENSE"
rp_module_repo="git https://github.com/libretro/bsnes-mercury master"
rp_module_section="opt"

function sources_lr-bsnes-mercury() {
    gitPullOrClone

    # Surpress Undefined Reference Errors When Building The Balanced Core
    sed -e "s|--no-undefined -Wl,||g" -i "${md_build}/Makefile"
}

function build_lr-bsnes-mercury() {
    local profiles=(
        'accuracy'
        'balanced'
        'performance'
    )

    for profile in "${profiles[@]}"; do
        make clean
        make PROFILE="${profile}"
    done

    md_ret_require=(
        "${md_build}/bsnes_mercury_accuracy_libretro.so"
        "${md_build}/bsnes_mercury_balanced_libretro.so"
        "${md_build}/bsnes_mercury_performance_libretro.so"
    )
}

function install_lr-bsnes-mercury() {
    md_ret_files=(
        'bsnes_mercury_accuracy_libretro.so'
        'bsnes_mercury_balanced_libretro.so'
        'bsnes_mercury_performance_libretro.so'
    )
}

function configure_lr-bsnes-mercury() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "snes"
        defaultRAConfig "snes"
    fi

    addEmulator 0 "${md_id}-a" "snes" "${md_inst}/bsnes_mercury_accuracy_libretro.so"
    addEmulator 0 "${md_id}-b" "snes" "${md_inst}/bsnes_mercury_balanced_libretro.so"
    addEmulator 0 "${md_id}-p" "snes" "${md_inst}/bsnes_mercury_performance_libretro.so"

    addSystem "snes"
}
