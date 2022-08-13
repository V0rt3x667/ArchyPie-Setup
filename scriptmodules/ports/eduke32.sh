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

    ! isPlatform "x86" && params+=(NOASM=1)
    ! isPlatform "x11" && params+=(HAVE_GTK2=0)
    ! isPlatform "gl3" && params+=(POLYMER=0)
    ! ( isPlatform "gl" || isPlatform "mesa" ) && params+=(USE_OPENGL=0)

    make veryclean
    make "${params[@]}"

    md_ret_require="$md_build/eduke32"
}

function install_eduke32() {
    md_ret_files=('eduke32' 'mapster32')
}

function _game_data_eduke32() {
    local dest 
    dest="$romdir/ports/b-engine/duke3d"
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
    declare -A games=(
        ['duke3d/duke3d.grp']="Duke Nukem 3D"
        ['duke3d/dukedc.grp']="Duke Nukem 3D: Duke It Out in D.C."
        ['duke3d/nwinter.grp']="Duke Nukem 3D: Duke: Nuclear Winter"
        ['duke3d/vacation.grp']="Duke Nukem 3D: Duke Caribbean: Life's a Beach"
        ['nam/nam.grp']="NAM (AKA Napalm)"
        ['nam/napalm.grp']="Napalm (AKA NAM)"
    )

    # Create .sh files for each game found. Uppercase filenames will be converted to lowercase.
    for game in "${!games[@]}"; do
        dir="$romdir/ports/b-engine/${game%%/*}"
        if [[ "$md_mode" == "install" ]]; then
            pushd "$dir"
            perl-rename 'y/A-Z/a-z/' [^.-]{*,*/*}
            popd
        fi
        if [[ -f "$dir/${game##*/}" ]]; then
            if [[ "$game" == "duke3d/duke3d.grp" ]]; then
                addPort "$md_id" "b-engine" "${games[$game]}" "pushd $md_conf_root/b-engine/$md_id; $md_inst/$md_id.sh %ROM%; popd" "-j $dir -addon 0"
            elif [[ "$game" == "duke3d/dukedc.grp" ]]; then
                addPort "$md_id" "b-engine" "${games[$game]}" "pushd $md_conf_root/b-engine/$md_id; $md_inst/$md_id.sh %ROM%; popd" "-j $dir -addon 1"
            elif [[ "$game" == "duke3d/nwinter.grp" ]]; then
                addPort "$md_id" "b-engine" "${games[$game]}" "pushd $md_conf_root/b-engine/$md_id; $md_inst/$md_id.sh %ROM%; popd" "-j $dir -addon 2"
            elif [[ "$game" == "duke3d/vacation.grp" ]]; then
                addPort "$md_id" "b-engine" "${games[$game]}" "pushd $md_conf_root/b-engine/$md_id; $md_inst/$md_id.sh %ROM%; popd" "-j $dir -addon 3"
            elif [[ "$game" == "nam/nam.grp" ]]; then
                addPort "$md_id" "b-engine" "${games[$game]}" "pushd $md_conf_root/b-engine/$md_id; $md_inst/$md_id.sh %ROM%; popd" "-j $dir -nam"
            elif [[ "$game" == "nam/napalm.grp" ]]; then
                addPort "$md_id" "b-engine" "${games[$game]}" "pushd $md_conf_root/b-engine/$md_id; $md_inst/$md_id.sh %ROM%; popd" "-j $dir -napalm"
            fi
        fi
    done

    if [[ "$md_mode" == "install" ]]; then
        # Use a dumb launcher script to strip quotes from runcommand's generated arguments.
        local binary
        binary="eduke32"

    cat > "$md_inst/$md_id.sh" << _EOF_
#!/bin/bash
$cmd \$*
_EOF_
    chmod +x "$md_inst/$md_id.sh"
    fi
}

function configure_eduke32() {
    if [[ "$md_mode" == "install" ]]; then
        mkRomDir "ports/b-engine"

        local dirs=('duke3d' 'nam')
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/b-engine/$dir"
        done

        _game_data_eduke32
    fi

    moveConfigDir "$arpiedir/ports/$md_id" "$md_conf_root/b-engine/$md_id"

    _add_games_eduke32 "$md_inst/eduke32"
}
