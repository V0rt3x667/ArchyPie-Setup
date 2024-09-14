#!/usr/bin/bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

rp_module_id="raze"
rp_module_desc="Raze: Build Engine Port"
rp_module_help="ROM Extensions: .grp\n\nCopy Game Files To:\n${romdir}/ports/buildengine/blood\n${romdir}/ports/buildengine/duke3d\n${romdir}/ports/buildengine/exhumed\n${romdir}/ports/buildengine/nam\n${romdir}/ports/buildengine/redneck\n${romdir}/ports/buildengine/redneck2\n${romdir}/ports/buildengine/shadow\n${romdir}/ports/buildengine/ww2gi"
rp_module_licence="NONCOM: https://raw.githubusercontent.com/coelckers/Raze/master/build-doc/buildlic.txt"
rp_module_repo="git https://github.com/coelckers/raze :_get_branch_raze"
rp_module_section="opt"
rp_module_flags="!all 64bit"

function _get_branch_raze() {
    download "https://api.github.com/repos/coelckers/raze/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_raze() {
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
        'libwebp'
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

function sources_raze() {
    gitPullOrClone

    _sources_zmusic_gzdoom

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"
}

function build_raze() {
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
        -DINSTALL_PK3_PATH="${md_inst}" \
        -DPK3_QUIET_ZIPDIR="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_raze() {
    md_ret_files=(
        'build/raze'
        'build/raze.pk3'
        'build/soundfonts'
        'package/common/buildlic.txt'
        'package/common/gamecontrollerdb.txt'
    )

    # Install ZMusic Library
    mkdir "${md_inst}/lib"
    cp -Pv "${md_build}"/zmusic/source/*.so* "${md_inst}/lib"
}

function configure_raze() {
    local portname
    portname="buildengine"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'addons'
            'addons/misc'
            'blood'
            'duke3d'
            'exhumed'
            'nam'
            'redneck'
            'redneck2'
            'shadow'
            'ww2gi'
        )
        mkRomDir "ports/${portname}"
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${portname}/${dir}"
        done

        # Create Default Config File
        cat > "${md_conf_root}/${portname}/${md_id}/raze.ini" << _INI_
[GameSearch.Directories]
Path=${romdir}/ports/buildengine
Path=${romdir}/ports/buildengine/*

[FileSearch.Directories]
Path=${romdir}/ports/buildengine
Path=${romdir}/ports/buildengine/*

[SoundfontSearch.Directories]
Path=\$PROGDIR/soundfonts
Path=/usr/share/soundfonts
_INI_
        chown "${__user}":"${__group}" "${md_conf_root}/${portname}/${md_id}/raze.ini"

        # Create A Launcher Script To Strip Quotes From 'runcommand.sh' Generated Arguments
        local params=("-fullscreen")

        # FluidSynth Is Too Memory/CPU Intensive, Use OPL Emulation For MIDI
        if isPlatform "arm"; then
            params+=("+set snd_mididevice -3")
        fi

        if isPlatform "kms"; then
            params+=("-width %XRES%" "-height %YRES%")
        fi

        cat > "${md_inst}/${md_id}.sh" << _EOF_
#!/bin/bash
grp="\${1}"
file="\${2}"

if [[ "\${grp}" =~ "cryptic.ini" ]]; then
    switch="-cryptic"
elif [[ "\${grp}" =~ "game66.con" ]]; then
    switch="-route66"
elif [[ "\${file}" =~ "addons" ]]; then
    switch="-iwad \${grp##*/} -file \${file}"
else
    switch="-iwad \${grp##*/}"
fi

${md_inst}/${md_id} \${switch} ${params[*]}
_EOF_
        chmod +x "${md_inst}/${md_id}.sh"

        _game_data_eduke32
    fi

    _add_games_eduke32 "${md_inst}/${md_id}.sh %ROM%"
}
