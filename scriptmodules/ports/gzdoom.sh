#!/usr/bin/env bash

# This file is part of the ArchPie project.
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
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_gzdoom() {
    gitPullOrClone
}

function _sources_zmusic() {
    tag="$(_get_branch_zmusic)"
    gitPullOrClone "$md_build/zmusic" "https://github.com/coelckers/ZMusic" "$tag"
    sed 's/\/sounds/\/soundfonts/g' -i "$md_build/zmusic/source/mididevices/music_fluidsynth_mididevice.cpp"
}

function _build_zmusic() {
    _sources_zmusic

    cd "$md_build/zmusic"
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DDYN_FLUIDSYNTH=OFF \
        -DDYN_MPG123=OFF \
        -DDYN_SNDFILE=OFF \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/zmusic/source/libzmusic.so"
}

function build_gzdoom() {
    _build_zmusic

    cd "$md_build"
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
        -DZMUSIC_LIBRARIES="$md_build/zmusic/build/source/libzmusic.so" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/gzdoom"
}

function install_gzdoom() {
    md_ret_files=(
        'build/brightmaps.pk3'
        'docs'
        'build/fm_banks'
        'build/game_support.pk3'
        'build/game_widescreen_gfx.pk3'
        'build/gzdoom'
        'build/gzdoom.pk3'
        'build/lights.pk3'
        'build/soundfonts'
    )
    mkdir "$md_inst/lib"
    mv $md_build/zmusic/build/source/libzmusic.so* "$md_inst/lib"
    mv $md_build/zmusic/build/source/libzmusiclite.so* "$md_inst/lib"
}

function _add_games_gzdoom() {
    local launcher_prefix="DOOMWADDIR=$romdir/ports/doom"
    _add_games_lr-prboom "$md_inst/gzdoom -iwad %ROM% +vid_renderer 1 +vid_fullscreen 1"
}

function configure_gzdoom() {
    mkRomDir ports/doom
    moveConfigDir "$home/.config/gzdoom" "$md_conf_root/doom"

    [[ "$md_mode" == "install" ]] && _add_games_gzdoom
}
