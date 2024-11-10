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
        download "https://api.github.com/repos/DirtBagXon/hypseus-singe/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
    fi
}

function depends_hypseus() {
    local depends=(
        'clang'
        'cmake'
        'libmpeg2'
        'libogg'
        'libvorbis'
        'libzip'
        'lld'
        'ninja'
        'sdl2_image'
        'sdl2_ttf'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_hypseus() {
    gitPullOrClone

    # Fix MPEG2 Build Error
    applyPatch "${md_data}/01_fix_mpeg2.patch"
}

function build_hypseus() {
    rpSwap on 1024

    cmake . \
        -B"build" \
        -G"Ninja" \
        -S"src" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -Wno-dev
    ninja -C build clean
    ninja -C build

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
            'bezels'
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

        local common_args="-framefile \"\${dir}/\${name}.txt\" -homedir \"${md_inst}\" -fullscreen -gamepad \${params}"
        # Prevents SDL Doing An Internal Software Conversion Since 2.0.16+
        isPlatform "arm" && common_args="-texturestream ${common_args}"

        # Create A Launcher Script
        cat >"${md_inst}/${md_id}.sh" <<_EOF_
#!/usr/bin/env bash
dir="\${1}"
name="\${dir##*/}"
name="\${name%.*}"

if [[ -f "\${dir}/\${name}.commands" ]]; then
    params=\$(<"\${dir}/\${name}.commands")
fi

if [[ -f "\${dir}/\${name}.singe" ]]; then
    singerom="\${dir}/\${name}.singe"
elif [[ -f "\${dir}/\${name}.zip" ]]; then
    singerom="\${dir}/\${name}.zip"
fi

if [[ -n "\${singerom}" ]]; then
    "${md_inst}/hypseus.bin" singe vldp -retropath -manymouse -script "\${singerom}" ${common_args}
else
    "${md_inst}/${md_id}.bin" "\${name}" vldp ${common_args}
fi
_EOF_
        chmod +x "${md_inst}/${md_id}.sh"
    fi

    addEmulator 1 "${md_id}" "daphne" "${md_inst}/${md_id}.sh %ROM%"

    addSystem "daphne"
}
