#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="supermodel"
rp_module_desc="Supermodel: Sega Model 3 Emulator"
rp_module_help="ROM Extension: .zip\n\nCopy Model 3 ROMs To: ${romdir}/model3"
rp_module_licence="GPL3 https://raw.githubusercontent.com/trzy/Supermodel/master/Docs/LICENSE.txt"
rp_module_repo="git https://github.com/trzy/Supermodel master"
rp_module_section="exp"
rp_module_flags="!all x86_64"

function depends_supermodel() {
    local depends=(
        'glu'
        'sdl2_net'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_supermodel() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|/.config|/ArchyPie/configs|g" -i "${md_build}/Src/OSD/Unix/FileSystemPath.cpp"
    sed -e "s|/.local/share|/ArchyPie/configs|g" -i "${md_build}/Src/OSD/Unix/FileSystemPath.cpp"
}

function build_supermodel() {
    make -f Makefiles/Makefile.UNIX clean
    make -f Makefiles/Makefile.UNIX NET_BOARD=1
    md_ret_require="${md_build}/bin/${md_id}"
}

function install_supermodel() {
    md_ret_files=(
        'Assets'
        'bin/supermodel'
        'Config'
    )
}

function configure_supermodel() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/model3/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "arcade"
        mkRomDir "model3"

        mkUserDir "${md_conf_root}/model3/${md_id}/Config"

        # Copy Default Config Files
        cp "${md_inst}/Config/Supermodel.ini" "${md_conf_root}/model3/${md_id}/Config"
        cp "${md_inst}/Config/Games.xml" "${md_conf_root}/model3/${md_id}/Config"
        chown -R "${user}:${user}" "${md_conf_root}/model3/${md_id}/Config"

        # Symlink NVRAM Folder
        moveConfigDir "${md_inst}/NVRAM" "${md_conf_root}/model3/${md_id}/NVRAM/"
    fi

    addEmulator 0 "${md_id}" "arcade" "pushd ${md_inst}; ${md_inst}/${md_id} -fullscreen %ROM%; popd"
    addEmulator 1 "${md_id}" "model3" "pushd ${md_inst}; ${md_inst}/${md_id} -fullscreen %ROM%; popd"

    addSystem "arcade"
    addSystem "model3"
}
