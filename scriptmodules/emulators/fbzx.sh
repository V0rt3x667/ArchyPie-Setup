#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="fbzx"
rp_module_desc="FBZX: ZX Spectrum 48K & 128 Emulator"
rp_module_help="ROM Extensions: .dsk .gz .img .mgt .scl .sna .szx .tap .trd .tzx .udi .z80 .zip\n\nCopy ZX Spectrum Games To: ${romdir}/zxspectrum"
rp_module_licence="GPL3 https://gitlab.com/rastersoft/fbzx/-/raw/master/COPYING"
rp_module_repo="git https://gitlab.com/rastersoft/fbzx :_get_branch_fbzx"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_fbzx() {
    download "https://gitlab.com/api/v4/projects/rastersoft%2Ffbzx/releases" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_fbzx() {
    local depends=(
        'ffmpeg'
        'sdl12-compat'
    )
    getDepends "${depends[@]}"
}

function sources_fbzx() {
    gitPullOrClone
}

function build_fbzx() {
    make clean
    make
    md_ret_require="${md_build}/src/${md_id}"
}

function install_fbzx() {
    make install PREFIX="${md_inst}"
    md_ret_require="${md_inst}/bin/${md_id}"
}

function configure_fbzx() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "zxspectrum"
    fi

    addEmulator 0 "${md_id}" "zxspectrum" "pushd ${md_inst}/share; ${md_inst}/bin/${md_id} -fs %ROM%; popd"

    addSystem "zxspectrum"
}
