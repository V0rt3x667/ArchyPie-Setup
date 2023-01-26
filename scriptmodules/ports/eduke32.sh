#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="eduke32"
rp_module_desc="EDuke32: Duke Nukem 3D, 'NAM & World War II GI Port"
rp_module_help="Copy .grp Files To:\n${romdir}/ports/duke3d/duke\n${romdir}/ports/duke3d/nam\n${romdir}/ports/duke3d/ww2gi"
rp_module_licence="GPL2 https://voidpoint.io/terminx/eduke32/-/raw/master/package/common/gpl-2.0.txt?inline=false"
rp_module_repo="git https://voidpoint.io/terminx/eduke32 master"
rp_module_section="opt"

function depends_eduke32() {
    local depends=(
        'flac'
        'freepats-general-midi'
        'libpng'
        'libvorbis'
        'libvpx'
        'perl-rename'
        'sdl2_mixer'
        'sdl2'
    )
    isPlatform "x86" && isPlatform "32bit" && depends+=('nasm')
    isPlatform "gl" || isPlatform "mesa" && depends+=('mesa' 'glu')
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
        md_ret_require="${md_build}/fury"
    else
        md_ret_require="${md_build}/eduke32"
    fi
}

function install_eduke32() {
    md_ret_files=('mapster32')

    if [[ "${md_id}" == "ionfury" ]]; then
        md_ret_files+=('fury')
    else
        md_ret_files+=('eduke32')
    fi
}

function _game_data_eduke32() {
    local dest
    dest="${romdir}/ports/duke3d/duke"

    if [[ -f "${dest}/duke3d.grp" ]] || [[ -f "${dest}/DUKE3D.GRP" ]]; then
        return
    else
        downloadAndExtract "${__arpie_url}/Duke3D/duke3d_assets_sw.tar.xz" "${dest}"
    fi
}

function _add_games_eduke32() {
    local cmd="$1"
    local dir
    local game
    local portname
    declare -A games=()

    if [[ "${md_id}" == "ionfury" ]]; then
        games=(['ionfury/fury.grp']="Ion Fury")
    else
        games=(
            ['duke/duke3d.grp']="Duke Nukem 3D"
            ['duke/dukedc.grp']="Duke Nukem 3D: Duke It Out in D.C."
            ['duke/nwinter.grp']="Duke Nukem 3D: Duke: Nuclear Winter"
            ['duke/vacation.grp']="Duke Nukem 3D: Duke Caribbean: Life's a Beach"
            ['nam/nam.grp']="NAM (AKA Napalm)"
            ['nam/napalm.grp']="Napalm (AKA NAM)"
            ['ww2gi/platoonl.dat']="World War II GI: Platoon Leader"
            ['ww2gi/ww2gi.grp']="World War II GI"
        )
    fi

    # Create .sh Files For Each Game Found. Uppercase Filenames Will Be Converted to Lowercase.
    for game in "${!games[@]}"; do
        if [[ "${md_id}" == "ionfury" ]]; then
            portname="ionfury"
            dir="${romdir}/ports/${portname}"
        else
            portname="duke3d"
            dir="${romdir}/ports/${portname}/${game%/*}"
        fi
        if [[ "${md_mode}" == "install" ]]; then
            pushd "${dir}" || return
            perl-rename 'y/A-Z/a-z/' [^.-]{*,*/*}
            popd || return
        fi
        if [[ -f "${dir}/${game##*/}" ]]; then
            if [[ "${game##*/}" == "fury.grp" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "pushd ${md_conf_root}/${md_id}; ${md_inst}/${md_id}.sh %ROM%; popd" "-j ${dir}"
            fi
            if [[ "${game##*/}" == "duke3d.grp" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "pushd ${md_conf_root}/${portname}/${md_id}; ${md_inst}/${md_id}.sh %ROM%; popd" "-j ${dir} -addon 0"
            elif [[ "${game##*/}" == "dukedc.grp" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "pushd ${md_conf_root}/${portname}/${md_id}; ${md_inst}/${md_id}.sh %ROM%; popd" "-j ${dir} -addon 1"
            elif [[ "${game##*/}" == "nwinter.grp" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "pushd ${md_conf_root}/${portname}/${md_id}; ${md_inst}/${md_id}.sh %ROM%; popd" "-j ${dir} -addon 2"
            elif [[ "${game##*/}" == "vacation.grp" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "pushd ${md_conf_root}/${portname}/${md_id}; ${md_inst}/${md_id}.sh %ROM%; popd" "-j ${dir} -addon 3"
            elif [[ "${game##*/}" == "ww2gi.grp" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "pushd ${md_conf_root}/${portname}/${md_id}; ${md_inst}/${md_id}.sh %ROM%; popd" "-j ${dir} -gamegrp ww2gi.grp -ww2gi"
            elif [[ "${game##*/}" == "platoonl.dat" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "pushd ${md_conf_root}/${portname}/${md_id}; ${md_inst}/${md_id}.sh %ROM%; popd" "-j ${dir} -gamegrp platoonl.dat -ww2gi"
            elif [[ "${game##*/}" == "nam.grp" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "pushd ${md_conf_root}/${portname}/${md_id}; ${md_inst}/${md_id}.sh %ROM%; popd" "-j ${dir} -nam"
            elif [[ "${game##*/}" == "napalm.grp" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "pushd ${md_conf_root}/${portname}/${md_id}; ${md_inst}/${md_id}.sh %ROM%; popd" "-j ${dir} -napalm"
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

function configure_eduke32() {
    if [[ "${md_mode}" == "install" ]]; then
        if [[ "${md_id}" == "ionfury" ]]; then
            local portname
            portname="ionfury"
            mkRomDir "ports/${portname}"
        elif [[ "${md_id}" == "eduke32" ]]; then
            local portname
            portname="duke3d"
            local dirs=('duke' 'nam' 'ww2gi')
            mkRomDir "ports/${portname}"
            for dir in "${dirs[@]}"; do
                mkRomDir "ports/${portname}/${dir}"
            done
            _game_data_eduke32
        fi
    fi

    if [[ "${md_id}" == "ionfury" ]]; then
        moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"
        _add_games_eduke32 "${md_inst}/fury"
    else
        moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"
        _add_games_eduke32 "${md_inst}/${md_id}"
    fi
}
