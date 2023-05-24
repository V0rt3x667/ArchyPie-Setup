#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="tsugaru"
rp_module_desc="Tsugaru: Fujitsu FM Towns & FM Towns Marty Emulator"
rp_module_help="ROM Extensions: .cue .d77 .iso \n\nCopy FM Towns Games To: ${romdir}/fmtowns \n\nCopy BIOS Files: \n\nFMT_DIC.ROM \nFMT_DOS.ROM \nFMT_F20.ROM \nFMT_FNT.ROM \nFMT_SYS.ROM \n\nTo: ${biosdir}/fmtowns"
rp_module_licence="BSD3 https://raw.githubusercontent.com/captainys/TOWNSEMU/master/LICENSE"
rp_module_repo="git https://github.com/captainys/TOWNSEMU master"
rp_module_section="exp"
rp_module_flags=""

function depends_tsugaru() {
    local depends=(
        'cmake'
        'gcc12'
        'ninja'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_tsugaru() {
    gitPullOrClone
}

function build_tsugaru() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -S"src" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="gcc-12" \
        -DCMAKE_CXX_COMPILER="g++-12" \
        -Wno-dev
    ninja -C build clean
    ninja -C build

    md_ret_require=("build/main_cui/Tsugaru_CUI")
}

function install_tsugaru() {
    md_ret_files=('build/main_cui/Tsugaru_CUI')
}

function configure_tsugaru() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "fmtowns"
        mkUserDir "${biosdir}/fmtowns"
    fi

    addEmulator 0 "${md_id}-fd" "fmtowns" "${md_inst}/Tsugaru_CUI ${biosdir}/fmtowns -FULLSCREEN -GAMEPORT0 KEY -FD0 %ROM%"
    addEmulator 1 "${md_id}-cd" "fmtowns" "${md_inst}/Tsugaru_CUI ${biosdir}/fmtowns -FULLSCREEN -GAMEPORT0 KEY -CD %ROM%"

    addSystem "fmtowns"
}
