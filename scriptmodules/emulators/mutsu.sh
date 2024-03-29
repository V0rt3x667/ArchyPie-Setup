#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="mutsu"
rp_module_desc="Mutsu: Fujitsu FM-7, 77AV, & 77AV40 Emulator"
rp_module_help="ROM Extensions: .d77 .t77\n\nCopy FM-7 Games To: ${romdir}/fm7\n\nCopy BIOS Files:\n\nBOOT_BAS.ROM\nBOOT_DOS.ROM\nFBASIC30.ROM\nINITIATE.ROM\nKANJI1.ROM\nSUBSYS_A.ROM\nSUBSYS_B.ROM\nSUBSYS_C.ROM\nSUBSYSCG.ROM\n\nTo: ${biosdir}/fm7"
rp_module_licence="BSD3 https://raw.githubusercontent.com/captainys/77AVEMU/master/LICENSE"
rp_module_repo="git https://github.com/captainys/77AVEMU master"
rp_module_section="exp"
rp_module_flags=""

function depends_mutsu() {
    local depends=(
        'cmake'
        'gcc12'
        'ninja'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_mutsu() {
    gitPullOrClone

    sources_tsugaru

    # Set Location Of External Dependencies
    sed -e "s|TOWNSEMU|tsugaru|g" -i "${md_build}/src/CMakeLists.txt"
}

function build_mutsu() {
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

    md_ret_require=("build/main_cui/Mutsu_CUI")
}

function install_mutsu() {
    md_ret_files=('build/main_cui/Mutsu_CUI')
}

function configure_mutsu() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "fm7"
        mkUserDir "${biosdir}/fm7"
    fi

    addEmulator 1 "${md_id}" "fm7" "${md_inst}/Mutsu_CUI ${biosdir}/fm7 -FULLSCREEN -FD0 %ROM%"
    addEmulator 0 "${md_id}-tape" "fm7" "${md_inst}/Mutsu_CUI ${biosdir}/fm7 -FULLSCREEN -AUTOSTARTTAPE -TAPE %ROM%"

    addSystem "fm7"
}
