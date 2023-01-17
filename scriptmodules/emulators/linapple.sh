#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="linapple"
rp_module_desc="LinApple-Pie: Apple II & IIe Emulator"
rp_module_help="ROM Extensions: .dsk .nib .po .sh .zip\n\nCopy Apple 2 Games To: ${romdir}/apple2"
rp_module_licence="GPL2 https://raw.githubusercontent.com/dabonetn/linapple-pie/master/LICENSE"
rp_module_repo="git https://github.com/dabonetn/linapple-pie master"
rp_module_section="opt"
rp_module_flags=""

function depends_linapple() {
    local depends=(
        'curl'
        'libzip'
        'sdl_image'
        'sdl12-compat'
    )
    getDepends "${depends[@]}"
}

function sources_linapple() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|/.linapple/|${md_conf_root}/apple2/${md_id}/|g" -i "${md_build}/src"/*.cpp
}

function build_linapple() {
    make -C src clean
    make -C src
    md_ret_require="${md_build}/${md_id}"
}

function install_linapple() {
    md_ret_files=(
        'CHANGELOG'
        'INSTALL'
        'LICENSE'
        'linapple.conf'
        'linapple'
        'Master.dsk'
        'README-linapple-pie'
        'README'
    )
}

function configure_linapple() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/apple2/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "apple2"

        # Copy Default Config & Disk If Not Installed
        local file
        for file in linapple.conf Master.dsk; do
            copyDefaultConfig "${file}" "${md_conf_root}/apple2/${md_id}/${file}"
        done
    fi

    addEmulator 1 "${md_id}" "apple2" "pushd ${md_conf_root}/apple2/${md_id}; ${md_inst}/${md_id} -f -1 %ROM% -r; popd"

    addSystem "apple2"
}
