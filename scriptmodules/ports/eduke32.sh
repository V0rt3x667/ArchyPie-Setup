#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="eduke32"
rp_module_desc="EDuke32: Duke Nukem 3D, 'NAM & World War II GI Port"
rp_module_help="Copy .grp Files To:\n${romdir}/ports/buildengine/duke3d\n${romdir}/ports/buildengine/nam\n${romdir}/ports/buildengine/ww2gi"
rp_module_licence="GPL2 https://voidpoint.io/terminx/eduke32/-/raw/master/package/common/gpl-2.0.txt"
rp_module_repo="git https://voidpoint.io/terminx/eduke32 master"
rp_module_section="opt"

function depends_eduke32() {
    local depends=(
        'flac'
        'freepats-general-midi'
        'libpng'
        'libvorbis'
        'libvpx'
        'sdl2_mixer'
        'sdl2'
    )
    isPlatform "x86" && isPlatform "32bit" && depends+=('nasm')
    isPlatform "gl" || isPlatform "mesa" && depends+=('glu' 'mesa')
    isPlatform "x11" && depends+=('gtk2')
    getDepends "${depends[@]}"
}

function sources_eduke32() {
    gitPullOrClone

    # Set Default Config Path(s)
    if [[ "${md_id}" == "ionfury" ]]; then
        sed -e "s|\".config/\" APPBASENAME|\"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/source/duke3d/src/common.cpp"
    else
        sed -e "s|\".config/\" APPBASENAME|\"ArchyPie/configs/\" APPBASENAME|g" -i "${md_build}/source/duke3d/src/common.cpp"
    fi
}

function build_eduke32() {
    local params=('LTO=1' 'SDL_TARGET=2' 'SDL_STATIC=0')

    [[ "${md_id}" == "ionfury" ]] && params+=('FURY=1')
    ! isPlatform "x86" && ! isPlatform "32bit" && params+=('NOASM=1')
    ! isPlatform "x11" && params+=('HAVE_GTK2=0')
    ! isPlatform "x86" && params+=('POLYMER=0')
    ! isPlatform "gl" || ! isPlatform "mesa" && params+=('USE_OPENGL=0')

    export CFLAGS+=" -DSDL_USEFOLDER"
    make veryclean
    make "${params[@]}"

    if [[ "${md_id}" == "ionfury" ]]; then
        # Rename Binary
        mv fury ionfury
        md_ret_require="${md_build}/ionfury"
    else
        md_ret_require="${md_build}/eduke32"
    fi
}

function install_eduke32() {
    if [[ "${md_id}" == "ionfury" ]]; then
        md_ret_files+=('ionfury')
    else
        md_ret_files+=('eduke32')
    fi
    md_ret_files=('mapster32')
}

function _game_data_eduke32() {
    local dest
    dest="${romdir}/ports/buildengine/duke3d"

    if [[ -f "${dest}/duke3d.grp" ]] || [[ -f "${dest}/DUKE3D.GRP" ]]; then
        return
    else
        downloadAndExtract "${__arpie_url}/Duke3D/duke3d_assets_sw.tar.xz" "${dest}"
    fi
}

function _add_games_eduke32() {
    local cmd="${1}"
    local dir
    local game
    local portname
    local wad

    declare -A games=()

    if [[ "${md_id}" == "ionfury" ]]; then
        games=(
            ['fury/fury.grp']="Ion Fury"
            ['aftershock/aftershock.grp']="Ion Fury: Aftershock"
        )
    else
        games=(
            ['duke3d/duke3d.grp']="Duke Nukem 3D"
            ['duke3d/dukedc.grp']="Duke Nukem 3D: Duke It Out in D.C."
            ['duke3d/nwinter.grp']="Duke Nukem 3D: Duke: Nuclear Winter"
            ['duke3d/vacation.grp']="Duke Nukem 3D: Duke Caribbean: Life's a Beach"
            ['nam/nam.grp']="NAM (AKA Napalm)"
            ['nam/napalm.grp']="Napalm (AKA NAM)"
            ['ww2gi/platoonl.dat']="World War II GI: Platoon Leader"
            ['ww2gi/ww2gi.grp']="World War II GI"
        )

        # Add Games That Currently Only Work On Raze
        if [[ "${md_id}" == "raze" ]]; then
            games+=(
                ['blood/blood.rff']="Blood"
                ['blood/cryptic.ini']="Blood: Cryptic Passage"
                ['duke3d/worldtour.grp']="Duke Nukem 3D: Twentieth Anniversary World Tour"
                ['exhumed/stuff.dat']="Exhumed (AKA PowerSlave)"
                ['redneck/game66.con']="Redneck Rampage: Suckin' Grits on Route 66"
                ['redneck/redneck.grp']="Redneck Rampage"
                ['redneck2/redneck2.grp']="Redneck Rampage II: Redneck Rampage Rides Again"
                ['shadow/sw.grp']="Shadow Warrior"
                ['shadow/td.grp']="Shadow Warrior: Twin Dragon"
                ['shadow/wt.grp']="Shadow Warrior: Wanton Destruction"
            )
        fi
    fi

    for game in "${!games[@]}"; do
        if [[ "${md_id}" == "ionfury" ]]; then
            portname="ionfury"
        else
            portname="buildengine"
        fi
        dir="${romdir}/ports/${portname}/${game%%/*}"
        wad="${romdir}/ports/${portname}/${game}"
        # Convert Uppercase Filenames To Lowercase
        [[ "${md_mode}" == "install" ]] && changeFileCase "${dir}"
        # Create Launch Scripts For Each Game Found
        if [[ -f "${wad}" ]]; then
            # Add Games Which Do Not Require Additional Parameters
            addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${wad}"
        fi

        # Add Games & Options That Only Work On Raze
        if [[ "${md_id}" == "raze" ]]; then
            # Load Addons From The 'misc' Folder
            local addon="${romdir}/ports/${portname}/addons/misc/*"
            addPort "${md_id}-addon" "${portname}" "${games[${game}]}" "${cmd} ${addon}" "${wad}"
        fi
    done
}

function configure_eduke32() {
    if [[ "${md_mode}" == "install" ]]; then
        local portname

        if [[ "${md_id}" == "ionfury" ]]; then
            portname="ionfury"
            local dirs=('aftershock' 'fury')
            mkRomDir "ports/${portname}"
            for dir in "${dirs[@]}"; do
                mkRomDir "ports/${portname}/${dir}"
            done
        else
            portname="buildengine"
            local dirs=('duke3d' 'nam' 'ww2gi')
            mkRomDir "ports/${portname}"
            for dir in "${dirs[@]}"; do
                mkRomDir "ports/${portname}/${dir}"
            done
            _game_data_eduke32
        fi

        # Create A Launcher Script To Pass EDuke32/IonFury Arguments To 'runcommand.sh'
        cat > "${md_inst}/${md_id}.sh" << _EOF_
#!/bin/bash
grp="\${1}"

if [[ "\${grp}" =~ "fury.grp" ]]; then
    dir="fury"
elif [[ "\${grp}" =~ "aftershock.grp" ]]; then
    dir="aftershock"
elif [[ "\${grp}" =~ "ww2gi.grp" ]]; then
    dir="ww2gi"
    switch="-gamegrp ww2gi.grp -ww2gi"
elif [[ "\${grp}" =~ "platoonl.dat" ]]; then
    dir="ww2gi"
    switch="-gamegrp platoonl.dat -ww2gi"
elif [[ "\${grp}" =~ "duke3d.grp" ]]; then
    dir="duke3d"
    switch="-addon 0"
elif [[ "\${grp}" =~ "dukedc.grp" ]]; then
    dir="duke3d"
    switch="-addon 1"
elif [[ "\${grp}" =~ "nwinter.grp" ]]; then
    dir="duke3d"
    switch="-addon 2"
elif [[ "\${grp}" =~ "vacation.grp" ]]; then
    dir="duke3d"
    switch="-addon 3"
elif [[ "\${grp}" =~ "nam.grp" ]]; then
    dir="nam"
    switch="-nam"
elif [[ "\${grp}" =~ "napalm.grp" ]]; then
    dir="nam"
    switch="-napalm"
fi

${md_inst}/${md_id} -j ${romdir}/ports/${portname}/\${dir} \${switch} -nosetup
_EOF_
        chmod +x "${md_inst}/${md_id}.sh"
    fi

    if [[ "${md_id}" == "ionfury" ]]; then
        moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"
    else
        moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"
    fi

    _add_games_eduke32 "${md_inst}/${md_id}.sh %ROM%"
}
