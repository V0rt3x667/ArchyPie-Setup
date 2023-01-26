#!/usr/bin/bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

rp_module_id="raze"
rp_module_desc="Raze: Build Engine Port"
rp_module_help="ROM Extensions: .grp\n\nCopy Game Files to:\n${romdir}/ports/duke3d/blood\n${romdir}/ports/duke3d/duke\n${romdir}/ports/duke3d/exhumed\n${romdir}/ports/duke3d/nam\n${romdir}/ports/duke3d/redneck\n${romdir}/ports/duke3d/shadow\n${romdir}/ports/duke3d/ww2gi"
rp_module_licence="NONCOM: https://raw.githubusercontent.com/coelckers/Raze/master/build-doc/buildlic.txt"
rp_module_repo="git https://github.com/coelckers/raze :_get_branch_raze"
rp_module_section="opt"
rp_module_flags="!all 64bit"

function _get_branch_raze() {
    download "https://api.github.com/repos/coelckers/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_raze() {
    local depends=(
        'alsa-lib'
        'cmake'
        'fluidsynth'
        'gtk3'
        'libjpeg-turbo'
        'ninja'
        'perl-rename'
        'openal'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_raze() {
    gitPullOrClone
    _sources_zmusic

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"
}

function build_raze() {
    _build_zmusic
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -Wl,-rpath='${md_inst}/lib'" \
        -DINSTALL_PK3_PATH="${md_inst}" \
        -DDYN_GTK="OFF" \
        -DDYN_OPENAL="OFF" \
        -DZMUSIC_INCLUDE_DIR="${md_build}/zmusic/include" \
        -DZMUSIC_LIBRARIES="${md_build}/zmusic/source/libzmusic.so" \
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
    mkdir "${md_inst}/lib"
    cp -Pv "${md_build}"/zmusic/source/*.so* "${md_inst}/lib"
}

function _add_games_raze() {
    local cmd="$1"
    local dir
    local game
    local portname
    declare -A games=(
        ['blood/blood.rff']="Blood"
        ['blood/cryptic.ini']="Blood: Cryptic Passage"
        ['duke/duke3d.grp']="Duke Nukem 3D"
        ['duke/dukedc.grp']="Duke Nukem 3D: Duke It Out in D.C."
        ['duke/nwinter.grp']="Duke Nukem 3D: Duke: Nuclear Winter"
        ['duke/vacation.grp']="Duke Nukem 3D: Duke Caribbean: Life's a Beach"
        ['duke/worldtour.grp']="Duke Nukem 3D: Twentieth Anniversary World Tour"
        ['exhumed/stuff.dat']="Exhumed (AKA PowerSlave)"
        ['nam/nam.grp']="NAM (AKA Napalm)"
        ['nam/napalm.grp']="Napalm (AKA NAM)"
        ['redneck/game66.con']="Redneck Rampage: Suckin' Grits on Route 66"
        ['redneck/redneck.grp']="Redneck Rampage"
        ['redneck/rides.grp']="Redneck Rampage II: Redneck Rampage Rides Again"
        ['shadow/sw.grp']="Shadow Warrior"
        ['shadow/td.grp']="Shadow Warrior: Twin Dragon"
        ['shadow/wt.grp']="Shadow Warrior: Wanton Destruction"
        ['ww2gi/platoonl.dat']="World War II GI: Platoon Leader"
        ['ww2gi/ww2gi.grp']="World War II GI"
    )

    # Create .sh Files For Each Game Found. Uppercase Filenames Will Be Converted to Lowercase.
    for game in "${!games[@]}"; do
        if [[ "${game%/*}" == "duke" ]] || [[ "${game%/*}" == "nam" ]] || [[ "${game%/*}" == "ww2gi" ]]; then
            portname="duke3d"
        else
            portname="raze"
        fi
        dir="${romdir}/ports/${portname}/${game%/*}"
        if [[ "${md_mode}" == "install" ]]; then
            pushd "${dir}" || return
            perl-rename 'y/A-Z/a-z/' [^.-]{*,*/*}
            popd || return
        fi
        if [[ -f "${dir}/${game##*/}" ]]; then
            if [[ "${game##*/}" == "cryptic.ini" ]]; then
                # Add Blood: Cryptic Passage
                addPort "${md_id}" "${portname}" "${games[$game]}" "${md_inst}/${md_id}.sh %ROM%" "-cryptic"
            elif [[ "${game##*/}" == "game66.con" ]]; then
                # Add Redneck Rampage: Suckin' Grits on Route 66
                addPort "${md_id}" "${portname}" "${games[$game]}" "${md_inst}/${md_id}.sh %ROM%" "-route66"
            elif [[ "${game##*/}" != "cryptic.ini" ]] && [[ "${game##*/}" != "game66.con" ]]; then
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

function configure_raze() {
    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'duke3d/addons'
            'duke3d/addons/misc'
            'duke3d/duke'
            'duke3d/nam'
            'duke3d/ww2gi'
            'raze/addons'
            'raze/addons/misc'
            'raze/blood'
            'raze/exhumed'
            'raze/redneck'
            'raze/shadow'
        )
        mkRomDir "ports/duke3d"
        mkRomDir "ports/raze"
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${dir}"
        done
        _game_data_eduke32
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    _add_games_raze "${md_inst}/${md_id} +vid_renderer 1 +vid_fullscreen 1"
}
