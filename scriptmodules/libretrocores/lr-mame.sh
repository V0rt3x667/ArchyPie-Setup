#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mame"
rp_module_desc="MAME (Latest Version) Libretro Core"
rp_module_help="ROM Extension: .zip\n\nCopy MAME ROMs To Either: ${romdir}/mame-libretro\n${romdir}/arcade\n\nIf You Wish To Have Seperate Systems For Sega Titan Video (ST-V), Naomi, Naomi 2, SNK Neo Geo (MVS) & Sammy Atomiswave Copy Their ROMs To:\n${romdir}/segastv\n${romdir}/naomi\n${romdir}/naomi2\n${romdir}/neogeo\n${romdir}/atomiswave"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mame/master/COPYING"
rp_module_repo="git https://github.com/libretro/mame master"
rp_module_section="exp"
rp_module_flags=""

function _get_params_lr-mame() {
    local params=(
        'CONFIG=libretro'
        'NO_USE_MIDI=1'
        'NO_USE_PORTAUDIO=1'
        'NOWERROR=1'
        'OPTIMIZE=2'
        'OS=linux'
        'OSD=retro'
        'PYTHON_EXECUTABLE=python'
        'RETRO=1'
        'TARGET=mame'
        'TARGETOS=linux'
    )
    isPlatform "64bit" && params+=('PTR64=1')
    echo "${params[@]}"
}

function depends_lr-mame() {
    local depends=('ffmpeg')
    isPlatform "gles" && depends+=('libglvnd')
    isPlatform "gl" && depends+=('glu')
    getDepends "${depends[@]}"
}

function sources_lr-mame() {
    gitPullOrClone
}

function build_lr-mame() {
    if isPlatform "64bit"; then
        rpSwap on 10240
    else
        rpSwap on 6144
    fi

    local params=($(_get_params_lr-mame) 'SUBTARGET=arcade')
    make clean
    make "${params[@]}"
    rpSwap off
    md_ret_require="${md_build}/mamearcade_libretro.so"
}

function install_lr-mame() {
    md_ret_files=('mamearcade_libretro.so')
}

function configure_lr-mame() {
    local core="${1}"
    [[ -z "${core}" ]] && core="mamearcade_libretro.so"

    local systems=(
        'arcade'
        'atomiswave'
        'mame-libretro'
        'naomi'
        'naomi2'
        'neogeo'
        'segastv'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            mkUserDir "${biosdir}/${system}"
            defaultRAConfig "${system}"

            # Create BIOS Directories For The MAME Cores
            local dir
            if [[ "${md_id}" == "lr-mame2010" ]]; then
                dir="mame2010"
            elif [[ "${md_id}" == "lr-mame2016" ]]; then
                dir="mame2016"
            else
                dir="mame"
            fi

            [[ ! -d "${biosdir}/mame-libretro/${dir}" ]] && mkUserDir "${biosdir}/mame-libretro/${dir}"

            if [[ "${system}" != "mame-libretro" ]]; then
                ln -snf "${biosdir}/mame-libretro/${dir}" "${biosdir}/${system}/${dir}"
            fi
        done
    fi

    for system in "${systems[@]}"; do
        addEmulator 0 "${md_id}" "${system}" "${md_inst}/${core}"
        addSystem "${system}"
    done
}
