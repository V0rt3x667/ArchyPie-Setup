#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="gzdoom"
rp_module_desc="GZDoom - Enhanced DOOM Port"
rp_module_licence="GPL3 https://raw.githubusercontent.com/coelckers/gzdoom/master/LICENSE"
rp_module_repo="git https://github.com/coelckers/gzdoom.git :_get_branch_gzdoom"
rp_module_section="opt"
rp_module_flags="!all x86 64bit"

function _get_branch_gzdoom() {
    download https://api.github.com/repos/coelckers/gzdoom/releases - | grep -m 1 tag_name | cut -d\" -f4
}

function _get_branch_zmusic() {
    download https://api.github.com/repos/coelckers/zmusic/tags - | grep -m 1 name | cut -d\" -f4
}

function depends_gzdoom() {
    depends=(
        'alsa-lib'
        'cmake'
        'fluidsynth'
        'gtk3'
        'libjpeg-turbo'
        'openal'
        'perl-rename'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_gzdoom() {
    gitPullOrClone
    _sources_zmusic
    applyPatch "$md_data/01_set_default_config_path.patch"
}

function _sources_zmusic() {
    tag="$(_get_branch_zmusic)"
    gitPullOrClone "$md_build/zmusic" "https://github.com/coelckers/ZMusic" "$tag"
    sed 's|/sounds/sf2|/soundfonts|g' -i "$md_build/zmusic/source/mididevices/music_fluidsynth_mididevice.cpp"
}

function _build_zmusic() {
    cmake . \
        -Szmusic \
        -Bzmusic \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DDYN_FLUIDSYNTH=OFF \
        -DDYN_MPG123=OFF \
        -DDYN_SNDFILE=OFF \
        -Wno-dev
    ninja -C zmusic clean
    ninja -C zmusic
    md_ret_require="$md_build/zmusic/source/libzmusic.so"
}

function build_gzdoom() {
    _build_zmusic
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -Wl,-rpath='$md_inst/lib'" \
        -DDYN_GTK=OFF \
        -DDYN_OPENAL=OFF \
        -DZMUSIC_INCLUDE_DIR="$md_build/zmusic/include" \
        -DZMUSIC_LIBRARIES="$md_build/zmusic/source/libzmusic.so" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/gzdoom"
}

function install_gzdoom() {
    md_ret_files=(
        'build/brightmaps.pk3'
        'build/fm_banks'
        'build/game_support.pk3'
        'build/game_widescreen_gfx.pk3'
        'build/gzdoom'
        'build/gzdoom.pk3'
        'build/lights.pk3'
        'build/soundfonts'
        'docs'
    )
    mkdir "$md_inst/lib"
    cp -Pv "$md_build"/zmusic/source/*.so* "$md_inst/lib"
}

function configure_gzdoom() {
    if [[ "$md_mode" == "install" ]]; then
        local dirs=(
            'addons'
            'addons/bloom'
            'addons/brutal'
            'addons/misc'
            'addons/sigil'
            'chex'
            'doom1'
            'doom2'
            'finaldoom'
            'freedoom'
            'hacx'
            'heretic'
            'strife'
        )
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/doom"
            mkRomDir "ports/doom/$dir"
        done

        _game_data_lr-prboom
    fi

    moveConfigDir "$arpiedir/ports/$md_id" "$md_conf_root/doom/$md_id"

    local launcher_prefix="DOOMWADDIR=$romdir/ports/doom"
    _add_games_lr-prboom "$launcher_prefix $md_inst/gzdoom +vid_renderer 1 +vid_fullscreen 1 -iwad %ROM%"
}
