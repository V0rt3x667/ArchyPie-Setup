#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="eduke32"
rp_module_desc="EDuke32 - Duke Nukem 3D Port"
rp_module_licence="GPL2 https://voidpoint.io/terminx/eduke32/-/raw/master/package/common/gpl-2.0.txt?inline=false"
rp_module_repo="git https://voidpoint.io/terminx/eduke32.git master"
rp_module_section="opt"

function depends_eduke32() {
    local depends=(
        'flac' 
        'freepats-general-midi'
        'libpng'
        'libvorbis'
        'libvpx'
        'sdl2_mixer'
    )
    isPlatform "x86" && depends+=('nasm')
    isPlatform "gl" || isPlatform "mesa" && depends+=('mesa' 'glu')
    isPlatform "x11" && depends+=('gtk2')
    getDepends "${depends[@]}"
}

function sources_eduke32() {
    gitPullOrClone
}

function build_eduke32() {
    local params=(LTO=1 SDL_TARGET=2 SDL_STATIC=0)

    [[ "$md_id" == "ionfury" ]] && params+=(FURY=1)
    ! isPlatform "x86" && params+=(NOASM=1)
    ! isPlatform "x11" && params+=(HAVE_GTK2=0)
    ! isPlatform "gl3" && params+=(POLYMER=0)
    ! ( isPlatform "gl" || isPlatform "mesa" ) && params+=(USE_OPENGL=0)

    make veryclean
    make "${params[@]}"

    if [[ "$md_id" == "ionfury" ]]; then
        md_ret_require="$md_build/fury"
    else
        md_ret_require="$md_build/eduke32"
    fi
}

function install_eduke32() {
    md_ret_files=('mapster32')

    if [[ "$md_id" == "ionfury" ]]; then
        md_ret_files+=('fury')
    else
        md_ret_files+=('eduke32')
    fi
}

function game_data_eduke32() {
    local dest="$romdir/ports/duke3d"
    if [[ "$md_id" == "eduke32" ]]; then
        if [[ ! -f "$dest/duke3d.grp" ]]; then
            mkUserDir "$dest"
            local temp="$(mktemp -d)"
            download "$__archive_url/3dduke13.zip" "$temp"
            unzip -L -o "$temp/3dduke13.zip" -d "$temp" dn3dsw13.shr
            unzip -L -o "$temp/dn3dsw13.shr" -d "$dest" duke3d.grp duke.rts
            rm -rf "$temp"
            chown -R $user:$user "$dest"
        fi
    fi
}

function configure_eduke32() {
    local appname="eduke32"
    local portname="duke3d"
    if [[ "$md_id" == "ionfury" ]]; then
        appname="fury"
        portname="ionfury"
    fi
    local config="$md_conf_root/$portname/settings.cfg"

    mkRomDir "ports/$portname"
    moveConfigDir "$home/.config/$appname" "$md_conf_root/$portname"

    _add_games_eduke32 "$md_inst/$appname"

    if [[ "$md_mode" == "install" ]]; then
        game_data_eduke32

        touch "$config"
        iniConfig " " '"' "$config"

        # enforce vsync for kms targets
        isPlatform "kms" && iniSet "r_swapinterval" "1"

        # the VC4 & V3D drivers render menu splash colours incorrectly without this
        isPlatform "mesa" && iniSet "r_useindexedcolortextures" "0"

        chown -R "$user:$user" "$config"
    fi
}

function _add_games_eduke32() {
    local binary="$1"
    local game
    local game_args
    local game_portname
    local game_launcher
    local num_games=4

    if [[ "$md_id" == "ionfury" ]]; then
        num_games=0
        local game0=('Ion Fury' '' '')
    else
        local game0=('Duke Nukem 3D' 'duke3d' '-addon 0')
        local game1=('Duke Nukem 3D: Duke It Out In D.C.' 'duke3d' '-addon 1')
        local game2=('Duke Nukem 3D: Duke: Nuclear Winter' 'duke3d' '-addon 2')
        local game3=('Duke Nukem 3D: Duke Caribbean: Life'\''s a Beach' 'duke3d' '-addon 3')
        local game4=('NAM' 'nam' '-nam')
    fi

    for ((game=0;game<=num_games;game++)); do
        game_launcher="game$game[0]"
        game_portname="game$game[1]"
        game_args="game$game[2]"

        if [[ -d "$romdir/ports/${!game_portname}" ]]; then
           addPort "$md_id" "${!game_portname}" "${!game_launcher}" "pushd $md_conf_root/${!game_portname}; ${binary}.sh %ROM%; popd" "-j$romdir/ports/${!game_portname} ${!game_args}"
        fi
    done

    if [[ "$md_mode" == "install" ]]; then
        # we need to use a dumb launcher script to strip quotes from runcommand's generated arguments
        cat > "${binary}.sh" << _EOF_
#!/bin/bash
# HACK: force vsync for RPI Mesa driver for now
VC4_DEBUG=always_sync $binary \$*
_EOF_
        chmod +x "${binary}.sh"
    fi
}
