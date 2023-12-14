#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-vice"
rp_module_desc="Commodore C64, C128, PET, Plus4 & VIC 20 Libretro Core"
rp_module_help="ROM Extensions: .cmd .crt .d64 .d71 .d80 .d81 .g64 .m3u .prg .t64 .tap .vsf .x64 .zip\n\nCopy C64 Games To: ${romdir}/c64"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/vice-libretro/master/vice/COPYING"
rp_module_repo="git https://github.com/libretro/vice-libretro master"
rp_module_section="opt"
rp_module_flags=""

function _get_targets_lr-vice() {
    echo x128 x64 x64dtv x64sc xpet xplus4 xvic
}

function sources_lr-vice() {
    gitPullOrClone
}

function build_lr-vice() {
    mkdir -p "${md_build}/cores"
    local target
    for target in $(_get_targets_lr-vice); do
        make clean
        make EMUTYPE="${target}"
        cp "${md_build}/vice_${target}_libretro.so" "cores/"
        md_ret_require+=("${md_build}/cores/vice_${target}_libretro.so")
    done
}

function install_lr-vice() {
    md_ret_files=(
        'vice/data'
    )
    local target
    for target in $(_get_targets_lr-vice); do
        md_ret_files+=("cores/vice_${target}_libretro.so")
    done
}

function configure_lr-vice() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "c64"
        defaultRAConfig "c64"

        isPlatform "arm" && setRetroArchCoreOption "vice_sid_engine" "FastSID"
    fi

    local target
    local name
    local def
    for target in $(_get_targets_lr-vice); do
        def=0
        name="-${target}"
        if [[ "${target}" == "x64" ]]; then
            name=""
            def=1
        fi
        addEmulator "${def}" "${md_id}${name}" "c64" "${md_inst}/vice_${target}_libretro.so"
    done

    addSystem "c64"
}
