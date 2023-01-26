#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="gzdoom"
rp_module_desc="GZDoom: Enhanced DOOM Port"
rp_module_licence="GPL3 https://raw.githubusercontent.com/coelckers/gzdoom/master/LICENSE"
rp_module_repo="git https://github.com/coelckers/gzdoom :_get_branch_gzdoom"
rp_module_section="opt"
rp_module_flags="!all 64bit"

function _get_branch_gzdoom() {
    download "https://api.github.com/repos/coelckers/${md_id}/releases" - | grep -m 1 tag_name | cut -d\" -f4
}

function _get_branch_zmusic() {
    download "https://api.github.com/repos/coelckers/zmusic/tags" - | grep -m 1 name | cut -d\" -f4
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

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"
}

function _sources_zmusic() {
    local tag 
    tag="$(_get_branch_zmusic)"

    gitPullOrClone "${md_build}/zmusic" "https://github.com/coelckers/ZMusic" "${tag}"

    # Fix Soundfonts Path
    sed -e "s|/sounds/sf2|/soundfonts|g" -i "${md_build}/zmusic/source/mididevices/music_fluidsynth_mididevice.cpp"
}

function _build_zmusic() {
    cmake . \
        -Szmusic \
        -Bzmusic \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DDYN_MPG123="OFF" \
        -DDYN_SNDFILE="OFF" \
        -Wno-dev
    ninja -C zmusic clean
    ninja -C zmusic
    md_ret_require="${md_build}/zmusic/source/libzmusic.so"
}

function build_gzdoom() {
    _build_zmusic
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -Wl,-rpath='${md_inst}/lib'" \
        -DDYN_GTK="OFF" \
        -DDYN_OPENAL="OFF" \
        -DZMUSIC_INCLUDE_DIR="${md_build}/zmusic/include" \
        -DZMUSIC_LIBRARIES="${md_build}/zmusic/source/libzmusic.so" \
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
    mkdir "${md_inst}/lib"
    cp -Pv "${md_build}"/zmusic/source/*.so* "${md_inst}/lib"
}

function _add_games_gzdoom() {
    local cmd="$1"
    local dir
    local game
    local portname
    declare -A games=(
        ['doom1/doom.wad']="Doom: The Ultimate Doom"
        ['doom1/doom1.wad']="Doom (Shareware)"
        ['doom1/doomu.wad']="Doom: The Ultimate Doom"
        ['doom2/doom2.wad']="Doom II: Hell on Earth"
        ['doom2/masterlevels.wad']="Doom II: Master Levels"
        ['finaldoom/plutonia.wad']="Final Doom: The Plutonia Experiment"
        ['finaldoom/tnt.wad']="Final Doom: TNT: Evilution"
        ['freedoom/freedoom1.wad']="Freedoom: Phase I"
        ['freedoom/freedoom2.wad']="Freedoom: Phase II"
        ['addons/bloom/bloom.pk3']="Doom II: Bloom"
        ['addons/brutal/brutal.pk3']="Doom: Brutal Doom"
        ['addons/brutal/brutality.pk3']="Doom: Project Brutality"
        ['addons/brutal/brutalwolf.pk3']="Doom: Brutal Wolfenstein"
        ['addons/sigil/sigil.wad']="Doom: SIGIL"
        ['addons/strain/strainfix.wad']="Doom II: Strain"
        ['chex/chex.wad']="Chex Quest"
        ['chex/chex2.wad']="Chex Quest 2"
        ['chex/chex3.wad']="Chex Quest 3"
        ['hacx/hacx.wad']="HacX"
        ['heretic/heretic.wad']="Heretic: Shadow of the Serpent Riders"
        ['heretic/hexdd.wad']="Hexen: Deathkings of the Dark Citadel"
        ['heretic/hexen.wad']="Hexen: Beyond Heretic"
        ['strife/strife1.wad']="Strife: Quest for the Sigil"
        )

    # Create .sh Files For Each Game Found. Uppercase Filenames Will Be Converted to Lowercase.
    for game in "${!games[@]}"; do
        portname="doom"
        dir="${romdir}/ports/${portname}/${game%/*}"
        if [[ "${md_mode}" == "install" ]]; then
            pushd "${dir}" || return
            perl-rename 'y/A-Z/a-z/' [^.-]{*,*/*}
            popd || return
        fi
        if [[ -f "${dir}/${game##*/}" ]]; then
            if [[ "${game##*/}" == "sigil.wad" ]] && [[ -f "${dir}/sigil_shreds.wad" ]]; then
                # Add Sigil & Buckethead Soundtrack if Available
                addPort "${md_id}" "${portname}" "${games[$game]}" "${md_inst}/${md_id}.sh %ROM%" "-iwad doom.wad -file sigil.wad -file ${dir}/sigil_shreds.wad"          
            elif [[ "${game##*/}" == "sigil.wad" ]] && [[ ! -f "${dir}/sigil_shreds.wad" ]]; then
                # Add Sigil
                addPort "${md_id}" "${portname}" "${games[$game]}" "${md_inst}/${md_id}.sh %ROM%" "-iwad doom.wad -file ${game##*/}" 
            elif [[ "${game##*/}" == "bloom.wad" ]]; then
                # Add Bloom
                addPort "${md_id}" "${portname}" "${games[$game]}" "${md_inst}/${md_id}.sh %ROM%" "-iwad doom2.wad -file ${game##*/}"         
            elif [[ "${game##*/}" == "strainfix.wad" ]]; then
                # Add Strain
                addPort "${md_id}" "${portname}" "${games[$game]}" "${md_inst}/${md_id}.sh %ROM%" "-iwad doom2.wad -file ${game##*/}"
            elif [[ "${game##*/}" =~ "brutal" ]]; then
                # Add Project Brutality and Other "Brutality" Mods if Available
                addPort "${md_id}" "${portname}" "${games[$game]}" "${md_inst}/${md_id}.sh %ROM%" "-iwad * -file ${game##*/}"
            else
                # Add Games Which Do Not Require Additional Parameters
                addPort "${md_id}" "${portname}" "${games[$game]}" "${md_inst}/${md_id}.sh %ROM%" "-iwad ${game##*/}"
                # Use addEmulator 0 to Prevent Addon Option From Becoming the Default
                addEmulator 0 "${md_id}-addon" "${portname}" "${md_inst}/${md_id}.sh %ROM% -file ${romdir}/ports/${portname}/addons/misc/*" "-iwad ${game##*/}"
            fi
        fi
    done

    if [[ "${md_mode}" == "install" ]]; then
        # Create a Launcher Script to Strip Quotes from runcommand's Generated Arguments.
        cat > "${md_inst}/${md_id}.sh" << _EOF_
#!/bin/bash
${cmd} \$*
_EOF_
        chmod +x "${md_inst}/${md_id}.sh"
    fi
}

function configure_gzdoom() {
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

    local launcher_prefix="DOOMWADDIR=${romdir}/ports/${portname}"
    _add_games_gzdoom "${launcher_prefix} ${md_inst}/${md_id} +vid_renderer 1 +vid_fullscreen 1"
}
