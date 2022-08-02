#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lzdoom"
rp_module_desc="LZDoom - DOOM Source Port (Legacy Version of GZDoom)"
rp_module_licence="GPL3 https://raw.githubusercontent.com/drfrag666/gzdoom/g3.3mgw/docs/licenses/README.TXT"
rp_module_repo="git https://github.com/drfrag666/gzdoom.git :_get_branch_lzdoom"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_lzdoom() {
    download https://api.github.com/repos/drfrag666/gzdoom/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_lzdoom() {
    local depends=(
        'bzip2'
        'cmake'
        'fluidsynth'
        'freepats-general-midi'
        'libev'
        'libgme'
        'libjpeg'
        'libsndfile'
        'mesa'
        'mpg123'
        'ninja'
        'openal'
        'perl-rename'
        'sdl2'
        'soundfont-fluid'
        'timidity'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_lzdoom() {
    gitPullOrClone
    applyPatch "$md_data/01_fix_file_paths.patch"
}

function build_lzdoom() {
    local params=()
    if isPlatform "armv8"; then
        params+=(-DUSE_ARMV8=On)
    fi
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        "${params[@]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/$md_id"
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

function _add_games_lzdoom() {
    local params=("+fullscreen 1")
    local launcher_prefix="DOOMWADDIR=$romdir/ports/doom"

    if isPlatform "mesa" || isPlatform "gl"; then
        params+=("+vid_renderer 1")
    elif isPlatform "gles"; then
        params+=("+vid_renderer 0")
    fi

    # FluidSynth is too memory/CPU intensive
    if isPlatform "arm"; then
        params+=("+'snd_mididevice -3'")
    fi

    if isPlatform "kms"; then
        params+=("+vid_vsync 1" "-width %XRES%" "-height %YRES%")
    fi

    _add_games_lr-prboom "$launcher_prefix $md_inst/$md_id -iwad %ROM% ${params[*]}"
}

function configure_lzdoom() {
    mkRomDir "ports/doom"

    moveConfigDir "$home/.config/$md_id" "$md_conf_root/doom"

    [[ "$md_mode" == "install" ]] && _game_data_lr-prboom

    _add_games_lzdoom
}
