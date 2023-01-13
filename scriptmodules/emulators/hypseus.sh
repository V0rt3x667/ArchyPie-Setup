#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="hypseus"
rp_module_desc="Hypseus Singe: Super Multiple Arcade Laserdisc Emulator"
rp_module_help="ROM Extension: .daphne\n\nCopy Laserdisc ROMs To: ${romdir}/daphne"
rp_module_licence="GPL3 https://raw.githubusercontent.com/DirtBagXon/hypseus-singe/master/LICENSE"
rp_module_repo="git https://github.com/DirtBagXon/hypseus-singe :_get_branch_hypseus"
rp_module_section="main"
rp_module_flags=""

function _get_branch_hypseus() {
    if isPlatform "rpi"; then
        RetroPie
    else
        download "https://api.github.com/repos/DirtBagXon/${md_id}-singe/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
    fi
}

function depends_hypseus() {
    local depends=(
        'cmake'
        'libmpeg2'
        'libogg'
        'libvorbis'
        'sdl2_image'
        'sdl2_ttf'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_hypseus() {
    gitPullOrClone
}

function build_hypseus() {
    # Not Currently Building With Ninja
    rpSwap on 1024
    cmake . \
        -Bbuild \
        -Ssrc \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -Wno-dev
    make -C build clean
    make -C build
    rpSwap off

    cp "build/${md_id}" "${md_id}.bin"
    md_ret_require="${md_build}/${md_id}.bin"
}

function install_hypseus() {
    md_ret_files=(
        'fonts'
        'hypseus.bin'
        'LICENSE'
        'pics'
        'sound'
    )
}

function configure_hypseus() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/daphne/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "daphne"
        mkRomDir "daphne/roms"

        local dirs=(
            'logs'
            'ram'
            'screenshots'
        )
        for dir in "${dirs[@]}"; do
            mkUserDir "${md_conf_root}/daphne/${md_id}/${dir}"
            ln -snf "${md_conf_root}/daphne/${md_id}/${dir}" "${md_inst}/${dir}"
        done

        copyDefaultConfig "${md_data}/hypinput.ini" "${md_conf_root}/daphne/${md_id}/hypinput.ini"

        ln -snf "${romdir}/daphne/roms" "${md_inst}/roms"
        ln -snf "${romdir}/daphne/roms" "${md_inst}/singe"
        ln -sf "${md_conf_root}/daphne/${md_id}/hypinput.ini" "${md_inst}/hypinput.ini"

        local common_args="-framefile \"\$dir/\$name.txt\" -homedir \"${md_inst}\" -fullscreen -gamepad \$params"

        cat >"${md_inst}/${md_id}.sh" <<_EOF_
#!/bin/bash
dir="\$1"
name="\${dir##*/}"
name="\${name%.*}"

if [[ -f "\$dir/\$name.commands" ]]; then
    params=\$(<"\$dir/\$name.commands")
fi

if [[ -f "\$dir/\$name.singe" ]]; then
    "${md_inst}/${md_id}.bin" singe vldp -retropath -manymouse -script "\$dir/\$name.singe" ${common_args}
else
    "${md_inst}/${md_id}.bin" "\$name" vldp ${common_args}
fi
_EOF_
        chmod +x "${md_inst}/${md_id}.sh"
        mkdir -p "${md_inst}/framefile"
    fi

    addEmulator 1 "${md_id}" "daphne" "${md_inst}/${md_id}.sh %ROM%"
    addSystem "daphne"
}
