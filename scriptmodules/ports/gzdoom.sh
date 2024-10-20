#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="gzdoom"
rp_module_desc="GZDoom: Enhanced Doom Port"
rp_module_licence="GPL3 https://raw.githubusercontent.com/coelckers/gzdoom/master/LICENSE"
rp_module_repo="git https://github.com/coelckers/gzdoom :_get_branch_gzdoom"
rp_module_section="opt"
rp_module_flags="!all 64bit"

function _get_branch_gzdoom() {
    download "https://api.github.com/repos/coelckers/gzdoom/releases" - | grep -m 1 tag_name | cut -d\" -f4
}

function _get_branch_zmusic_gzdoom() {
    download "https://api.github.com/repos/coelckers/zmusic/tags" - | grep -m 1 name | cut -d\" -f4
}

function depends_gzdoom() {
    local depends=(
        'alsa-lib'
        'bzip2'
        'clang'
        'cmake'
        'fluidsynth'
        'gtk3'
        'libjpeg-turbo'
        'libsndfile'
        'libvpx'
        'lld'
        'mpg123'
        'ninja'
        'openal'
        'openmp'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_gzdoom() {
    gitPullOrClone

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"

    # Get ZMusic Sources, Required For GZDoom & Raze
    _sources_zmusic_gzdoom
}

function _sources_zmusic_gzdoom() {
    local tag 
    tag="$(_get_branch_zmusic_gzdoom)"

    gitPullOrClone "${md_build}/zmusic" "https://github.com/coelckers/ZMusic" "${tag}"

    # Fix Soundfonts Path
    sed -e "s|/sounds/sf2|/soundfonts|g" -i "${md_build}/zmusic/source/mididevices/music_fluidsynth_mididevice.cpp"
}

function _build_zmusic_gzdoom() {
    cmake . \
        -B"zmusic" \
        -G"Ninja" \
        -S"zmusic" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -Wno-dev
    ninja -C zmusic clean
    ninja -C zmusic
    md_ret_require="${md_build}/zmusic/source/libzmusic.so"
}

function build_gzdoom() {
    _build_zmusic_gzdoom

    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -Wl,-rpath='${md_inst}/lib'" \
        -DZMUSIC_INCLUDE_DIR="${md_build}/zmusic/include" \
        -DZMUSIC_LIBRARIES="${md_build}/zmusic/source/libzmusic.so" \
        -DPK3_QUIET_ZIPDIR="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
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

    # Install ZMusic Library
    mkdir "${md_inst}/lib"
    cp -Pv "${md_build}"/zmusic/source/*.so* "${md_inst}/lib"
}

function configure_gzdoom() {
    local portname
    portname=doom

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'addons'
            'addons/bloom'
            'addons/brutal'
            'addons/hell'
            'addons/lost'
            'addons/masterlevels'
            'addons/misc'
            'addons/nerve'
            'addons/perdition'
            'addons/sigil'
            'addons/strain'
            'chex'
            'doom1'
            'doom2'
            'finaldoom'
            'freedoom'
            'hacx'
            'heretic'
            'square'
            'strife'
            'urban'
            'wboa'
        )
        mkRomDir "ports/${portname}"
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${portname}/${dir}"
        done

        # Create Default Config File
        cat > "${md_conf_root}/${portname}/${md_id}/gzdoom.ini" << _INI_
[IWADSearch.Directories]
Path=\$DOOMWADDIR/doom1
Path=\$DOOMWADDIR/doom2
Path=\$DOOMWADDIR/chex
Path=\$DOOMWADDIR/finaldoom
Path=\$DOOMWADDIR/freedoom
Path=\$DOOMWADDIR/hecx
Path=\$DOOMWADDIR/heretic
Path=\$DOOMWADDIR/strife
Path=\$DOOMWADDIR/wboa

[FileSearch.Directories]
Path=\$DOOMWADDIR/addons/bloom
Path=\$DOOMWADDIR/addons/brutal
Path=\$DOOMWADDIR/addons/masterlevels
Path=\$DOOMWADDIR/addons/misc
Path=\$DOOMWADDIR/addons/nerve
Path=\$DOOMWADDIR/addons/sigil
Path=\$DOOMWADDIR/addons/strain

[SoundfontSearch.Directories]
Path=\$PROGDIR/fm_banks
Path=\$PROGDIR/soundfonts
Path=/usr/share/fm_banks
Path=/usr/share/soundfonts
_INI_
        chown "${__user}":"${__group}" "${md_conf_root}/${portname}/${md_id}/gzdoom.ini"

        # Create A Launcher Script
        local launcher_prefix="DOOMWADDIR=${romdir}/ports/${portname}"
        local params=("-fullscreen")

        # FluidSynth Is Too Memory/CPU Intensive, Use OPL Emulation For MIDI
        if isPlatform "arm"; then
            params+=("+set snd_mididevice -3")
        fi

        if isPlatform "kms"; then
            params+=("-width %XRES%" "-height %YRES%")
        fi

        cat > "${md_inst}/${md_id}.sh" << _EOF_
#!/usr/bin/env bash
${launcher_prefix} ${md_inst}/${md_id} -iwad \${*} ${params[*]}
_EOF_
        chmod +x "${md_inst}/${md_id}.sh"

        # Get Shareware Data If Required
        _game_data_lr-prboom
    fi

    _add_games_lr-prboom "${md_inst}/${md_id}.sh %ROM%"
}
