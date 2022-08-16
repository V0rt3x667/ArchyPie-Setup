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
        'perl-rename'
        'sdl2'
        'sdl2_mixer'
    )
    isPlatform "x86" && depends+=('nasm')
    isPlatform "gl" || isPlatform "mesa" && depends+=('mesa' 'glu')
    isPlatform "x11" && depends+=('gtk2')
    getDepends "${depends[@]}"
}

function sources_eduke32() {
    gitPullOrClone

    applyPatch "$md_data/01_set_default_config_path.patch"
}

function build_eduke32() {
    local params=(LTO=1 SDL_TARGET=2 SDL_STATIC=0)

    [[ "$md_id" == "ionfury" ]] && params+=(FURY=1)
    ! isPlatform "x86" && params+=(NOASM=1)
    ! isPlatform "x11" && params+=(HAVE_GTK2=0)
    ! isPlatform "gl3" && params+=(POLYMER=0)
    ! ( isPlatform "gl" || isPlatform "mesa" ) && params+=(USE_OPENGL=0)

    make veryclean
    CFLAGS+=" -DSDL_USEFOLDER" make "${params[@]}"

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

function _game_data_eduke32() {
    local dest 
    dest="$romdir/ports/duke3d"

    if [[ -f "$dest/duke3d.grp" || -f "$dest/DUKE3D.GRP" ]]; then
        return
    else
        downloadAndExtract "$__arpie_url/Duke3D/duke3d_assets_sw.tar.xz" "$dest"
    fi
}

function _add_games_eduke32() {
    local cmd="$1"
    local dir
    local game
    declare -A games=()

    if [[ "$md_id" == "ionfury" ]]; then
        games=(['ionfury/fury.grp']="Ion Fury")
    fi
    if [[ "$md_id" == "eduke32" ]]; then
        games=(
            ['duke3d/duke3d.grp']="Duke Nukem 3D"
            ['duke3d/dukedc.grp']="Duke Nukem 3D: Duke It Out in D.C."
            ['duke3d/nwinter.grp']="Duke Nukem 3D: Duke: Nuclear Winter"
            ['duke3d/vacation.grp']="Duke Nukem 3D: Duke Caribbean: Life's a Beach"
            ['nam/nam.grp']="NAM (AKA Napalm)"
            ['nam/napalm.grp']="Napalm (AKA NAM)"
            ['ww2gi/ww2gi.grp']="World War II GI"
            ['ww2gi/platoonl.dat']="World War II GI: Platoon Leader"
        )
    fi

    # Create .sh Files For Each Game Found. Uppercase Filenames Will Be Converted to Lowercase.
    for game in "${!games[@]}"; do
        dir="$romdir/ports/${game%%/*}"
        if [[ "$md_mode" == "install" ]]; then
            pushd "$dir" || return
            perl-rename 'y/A-Z/a-z/' [^.-]{*,*/*}
            popd || return
        fi
        if [[ -f "$dir/${game##*/}" ]]; then
            if [[ "$game" == "ionfury/fury.grp" ]]; then
                addPort "$md_id" "${game%%/*}" "${games[$game]}" "pushd $md_conf_root/$md_id; $md_inst/$md_id.sh %ROM%; popd" "-j $dir"
            fi 
            if [[ "$game" == "duke3d/duke3d.grp" ]]; then
                addPort "$md_id" "${game%%/*}" "${games[$game]}" "pushd $md_conf_root/$md_id; $md_inst/$md_id.sh %ROM%; popd" "-j $dir -addon 0"
            elif [[ "$game" == "duke3d/dukedc.grp" ]]; then
                addPort "$md_id" "${game%%/*}" "${games[$game]}" "pushd $md_conf_root/$md_id; $md_inst/$md_id.sh %ROM%; popd" "-j $dir -addon 1"
            elif [[ "$game" == "duke3d/nwinter.grp" ]]; then
                addPort "$md_id" "${game%%/*}" "${games[$game]}" "pushd $md_conf_root/$md_id; $md_inst/$md_id.sh %ROM%; popd" "-j $dir -addon 2"
            elif [[ "$game" == "duke3d/vacation.grp" ]]; then
                addPort "$md_id" "${game%%/*}" "${games[$game]}" "pushd $md_conf_root/$md_id; $md_inst/$md_id.sh %ROM%; popd" "-j $dir -addon 3"
            elif [[ "$game" == "ww2gi/ww2gi.grp" ]]; then
                addPort "$md_id" "${game%%/*}" "${games[$game]}" "pushd $md_conf_root/$md_id; $md_inst/$md_id.sh %ROM%; popd" "-j $dir -ww2gi"
            elif [[ "$game" == "ww2gi/platoonl.dat" ]]; then
                addPort "$md_id" "${game%%/*}" "${games[$game]}" "pushd $md_conf_root/$md_id; $md_inst/$md_id.sh %ROM%; popd" "-j $dir -ww2gi"
            elif [[ "$game" == "nam/nam.grp" ]]; then
                addPort "$md_id" "${game%%/*}" "${games[$game]}" "pushd $md_conf_root/$md_id; $md_inst/$md_id.sh %ROM%; popd" "-j $dir -nam"
            elif [[ "$game" == "nam/napalm.grp" ]]; then
                addPort "$md_id" "${game%%/*}" "${games[$game]}" "pushd $md_conf_root/$md_id; $md_inst/$md_id.sh %ROM%; popd" "-j $dir -napalm"
            fi
        fi
    done

    if [[ "$md_mode" == "install" ]]; then
        # Use a Launcher Script to Strip Quotes From Runcommand's Generated Arguments.
        cat > "$md_inst/$md_id.sh" << _EOF_
#!/bin/bash
$cmd \$*
_EOF_
        chmod +x "$md_inst/$md_id.sh"
    fi
}

function configure_eduke32() {
    if [[ "$md_mode" == "install" ]]; then
        local dirs
        if [[ "$md_id" == "ionfury" ]]; then
            dirs=('ionfury')
        else
            dirs=('duke3d' 'nam' 'ww2gi')
        fi
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/$dir"
        done
        [[ "$md_id" == "eduke32" ]] && _game_data_eduke32
    fi

    moveConfigDir "$arpiedir/ports/$md_id" "$md_conf_root/$md_id/"

    if [[ "$md_id" == "ionfury" ]]; then
        _add_games_eduke32 "$md_inst/fury"
    else
        _add_games_eduke32 "$md_inst/eduke32"
    fi
}
