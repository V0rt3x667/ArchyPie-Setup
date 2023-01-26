#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lzdoom"
rp_module_desc="LZDoom: DOOM Source Port (Legacy Version of GZDoom)"
rp_module_licence="GPL3 https://raw.githubusercontent.com/drfrag666/gzdoom/g3.3mgw/docs/licenses/README.TXT"
rp_module_repo="git https://github.com/drfrag666/gzdoom :_get_branch_lzdoom"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_lzdoom() {
    download "https://api.github.com/repos/drfrag666/gzdoom/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_lzdoom() {
    depends_gzdoom
}

function sources_lzdoom() {
    gitPullOrClone

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"

    if isPlatform "arm"; then
        # Patch the CMake Build File to Remove the ARMv8 Options, CPU Flags Are Set In "system.sh"
        applyPatch "${md_data}/02_remove_cmake_arm_options.patch"
    fi
}

function build_lzdoom() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DPK3_QUIET_ZIPDIR="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_lzdoom() {
    md_ret_files=(
        'README.md'
        'build/brightmaps.pk3'
        'build/fm_banks'
        'build/game_support.pk3'
        'build/lights.pk3'
        'build/lzdoom'
        'build/lzdoom.pk3'
        'build/soundfonts'
    )
}

function configure_lzdoom() {
    local portname
    portname=doom

    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'addons'
            'addons/bloom'
            'addons/brutal'
            'addons/misc'
            'addons/sigil'
            'addons/strain'
            'chex'
            'doom1'
            'doom2'
            'finaldoom'
            'freedoom'
            'hacx'
            'heretic'
            'strife'
        )
        mkRomDir "ports/${portname}"
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${portname}/${dir}"
        done

        _game_data_lr-prboom
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}"

    local params=("+fullscreen 1")
    local launcher_prefix="DOOMWADDIR=${romdir}/ports/${portname}"

    if isPlatform "mesa" || isPlatform "gl"; then
        params+=("+vid_renderer 1")
    elif isPlatform "gles"; then
        params+=("+vid_renderer 0")
    fi

    # FluidSynth Is Too Memory/CPU Intensive
    if isPlatform "arm"; then
        params+=("+'snd_mididevice -3'")
    fi

    if isPlatform "kms"; then
        params+=("+vid_vsync 1" "-width %XRES%" "-height %YRES%")
    fi

    _add_games_gzdoom "${launcher_prefix} ${md_inst}/${md_id} ${params[*]}"
}
