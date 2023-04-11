#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="openbor"
rp_module_desc="OpenBOR: Beat 'Em Up Game Engine"
rp_module_help="Copy .pak Files to: ${romdir}/ports/openbor"
rp_module_licence="BSD https://raw.githubusercontent.com/DCurrent/openbor/master/LICENSE"
rp_module_repo="git https://github.com/DCurrent/openbor master"
rp_module_section="exp"
rp_module_flags="!mali"

function depends_openbor() {
    local depends=(
        'libogg'
        'libpng'
        'libvorbis'
        'libvpx'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_openbor() {
    gitPullOrClone

    # Fix Locale Warning
    sed -e "s|en_US.UTF-8|C|g" -i "${md_build}/engine/version.sh"

    # Disable Abort On Warnings & Errors
    sed -e "s|-Werror||g" -i "${md_build}/engine/Makefile"

    # Set Fullscreen By Default
    sed -e "s|savedata.fullscreen = 0;|savedata.fullscreen = 1;|g" -i "${md_build}/engine/openbor.c"
}

function build_openbor() {
    cd "${md_build}/engine" || exit
    ./version.sh
    ./build.sh 4

    cd "${md_build}/tools/borpak/source" || exit
    chmod a+x ./build.sh
    ./build.sh lin
    md_ret_require="${md_build}/engine/releases/LINUX/OpenBOR/OpenBOR"
}

function install_openbor() {
    md_ret_files=('engine/releases/LINUX/OpenBOR/OpenBOR')
}

function configure_openbor() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        # Create Launcher Script
        cat >"${md_inst}/${md_id}.sh" << _EOF_
#!/bin/bash
pushd "${md_inst}"
./OpenBOR "\$@"
popd
_EOF_
        chmod +x "${md_inst}/${md_id}.sh"

        local dirs=(
            'Logs'
            'Saves'
            'ScreenShots'
        )
        for dir in "${dirs[@]}"; do
            mkUserDir "${md_conf_root}/${md_id}/${dir}"
            ln -snf "${md_conf_root}/${md_id}/${dir}" "${md_inst}/${dir}"
        done

        ln -snf "${romdir}/ports/${md_id}" "${md_inst}/Paks"
    fi

    addPort "${md_id}" "${md_id}" "OpenBOR: Beats of Rage Engine" "${md_inst}/${md_id}.sh"

    mkRomDir "ports/${md_id}"
}
