#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="quasi88"
rp_module_desc="QUASI88: NEC PC-8801 Emulator"
rp_module_help="ROM Extensions: .88d .cmt .d88 .t88\n\nCopy PC-88 Games To: ${romdir}/pc88\n\nCopy BIOS Files:\nFONT.ROM\nN88.ROM\nN88KNJ1.ROM\nN88KNJ2.ROM\nN88SUB.ROM\nTo ${biosdir}/pc88"
rp_module_licence="BSD3 https://raw.githubusercontent.com/winterheart/quasi88/master/LICENSE.txt"
rp_module_repo="git https://github.com/winterheart/quasi88 :_get_branch_quasi88"
rp_module_section="exp"
rp_module_flags=""

function _get_branch_quasi88() {
    download "https://api.github.com/repos/winterheart/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_quasi88() {
    local depends=(
        'cmake'
        'ninja'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_quasi88() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|path(env_home) / \".quasi88\"|path(env_home) / \"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/src/file-op.cpp"
}

function build_quasi88() {
    local params=()

    isPlatform "x11" && params+=('-DENABLE_X11=ON')
    
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DENABLE_JOYSTICK="SDL" \
        "${params[@]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}.sdl"
}

function install_quasi88() {
    md_ret_files=(
        'build/quasi88.sdl'
        'keyconf.rc'
        'quasi88.rc'
    )
}

function configure_quasi88() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/pc88/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "pc88"
        mkUserDir "${biosdir}/pc88"

        # Symlink ROM, Disk & Tape Directories
        ln -snf "${biosdir}/pc88" "${md_conf_root}/pc88/${md_id}/rom"
        ln -snf "${romdir}/pc88" "${md_conf_root}/pc88/${md_id}/disk"
        ln -snf "${romdir}/pc88" "${md_conf_root}/pc88/${md_id}/tape"
    fi

    addEmulator 1 "${md_id}" "pc88" "${md_inst}/${md_id}.sdl -f6 IMAGE-NEXT1 -f7 IMAGE-NEXT2 -f8 NOWAIT -f9 ROMAJI -f10 NUMLOCK -fullscreen %ROM%"

    addSystem "pc88"
}
