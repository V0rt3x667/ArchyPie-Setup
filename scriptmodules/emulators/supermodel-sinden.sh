#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="supermodel-sinden"
rp_module_desc="Supermodel: Sega Model 3 Emulator (DirtBagXon Fork With Sinden Light Gun Support)"
rp_module_help="ROM Extension: .zip\n\nCopy Model 3 ROMs To: ${romdir}/model3"
rp_module_licence="GPL3 https://raw.githubusercontent.com/DirtBagXon/model3emu-code-sinden/main/Docs/LICENSE.txt"
rp_module_repo="git https://github.com/DirtBagXon/model3emu-code-sinden :_get_branch_supermodel-sinden"
rp_module_section="exp"
rp_module_flags="all !armv7 !kms"

function _get_branch_supermodel-sinden() {
    if isPlatform "x86"; then
        echo "main"
    else
        echo "arm"
    fi
}

function depends_supermodel-sinden() {
    local depends=(
        'glu'
        'libxi'
        'sdl2_net'
        'sdl2'
        'zlib'
    )

    # On KMS We Need x11 To Start The Emulator (Needs Working On)
    #isPlatform "kms" && depends+=(xorg matchbox-window-manager)
    getDepends "${depends[@]}"
}

function sources_supermodel-sinden() {
    gitPullOrClone

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"
}

function build_supermodel-sinden() {
    make -f Makefiles/Makefile.UNIX clean
    make -f Makefiles/Makefile.UNIX NET_BOARD=1 VERBOSE=1 ARCH="" OPT="${__default_cflags}"

    md_ret_require="${md_build}/bin/supermodel"
}

function install_supermodel-sinden() {
    md_ret_files=(
        'bin/supermodel'
        'Config'
        'Docs/LICENSE.txt'
        'Docs/README.txt'
    )
    isPlatform "x86" && md_ret_files+=("Assets")
}

function configure_supermodel-sinden() {
    local systems=(
        'arcade'
        'model3'
    )

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/model3/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
        done

        local conf_dir
        local dir
        local dirs=(
            'NVRAM'
            'Saves'
            'Config'
        )
        isPlatform "x86" && dirs+=('Assets')

        conf_dir="${md_conf_root}/model3/${md_id}"
        for dir in "${dirs[@]}"; do
            mkUserDir "${conf_dir}/${dir}"
        done

        # On Upgrades Keep The Local Config, But Overwrite The Game Configs
        copyDefaultConfig "${md_inst}/Config/Supermodel.ini" "${conf_dir}/Config/Supermodel.ini"
        cp -f "${md_inst}/Config/Games.xml" "${conf_dir}/Config"
        isPlatform "x86" && cp -fr "${md_inst}/Assets" "${conf_dir}"
        chown -R "${__user}":"${__group}" "${conf_dir}"

        # Create Launcher Script
        cat >"${md_inst}/supermodel.sh" <<_EOF_
#!/usr/bin/env bash

commands="\${1%.*}.commands"

if [[ -f "\${commands}" ]]; then
    params=\$(<"\${commands}" tr -d '\r' | tr '\n' ' ')
fi

${md_inst}/supermodel "\${@}" \${params}
_EOF_
        chmod +x "${md_inst}/supermodel.sh"
    fi

    local game_args="-vsync"
    local launch_prefix=""

    # Launch The Emulator With An X11 Backend, Has Better Scaling And Mouse/Lightgun Support
    isPlatform "kms" && launch_prefix="XINIT:"

    for system in "${systems[@]}"; do
        addEmulator 1 "${md_id}"        "${system}" "${launch_prefix}${md_inst}/supermodel.sh %ROM% ${game_args}"
        addEmulator 0 "${md_id}-scaled" "${system}" "${launch_prefix}${md_inst}/supermodel.sh %ROM% ${game_args} -res=%XRES%,%YRES%"
        if isPlatform "x86"; then
            # Add A Legacy3d Entry For Less Powerful PC Systems
            addEmulator 0 "${md_id}-legacy3d" "${system}" "${md_inst}/supermodel.sh %ROM% -legacy3d ${game_args}"
        fi
        addSystem "${system}"
    done
}
