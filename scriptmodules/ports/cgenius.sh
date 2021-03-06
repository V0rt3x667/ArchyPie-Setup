#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="cgenius"
rp_module_desc="Commander Genius - Modern Interpreter for the Commander Keen Games (Vorticon and Galaxy Games)"
rp_module_licence="GPL2 https://raw.githubusercontent.com/gerstrong/Commander-Genius/master/COPYRIGHT"
rp_module_repo="git https://gitlab.com/Dringgstein/Commander-Genius.git :_get_branch_cgenius"
rp_module_section="exp"

function _get_branch_cgenius() {
    download https://gitlab.com/api/v4/projects/Dringgstein%2FCommander-Genius/releases - | grep -m 1 tag_name | cut -d\" -f8
}

function depends_cgenius() {
    local depends=(
        'cmake'
        'curl'
        'ninja'
        'perl-rename'
        'sdl2'
        'sdl2_image' 
        'sdl2_mixer'
        'sdl2_ttf'
    )
    getDepends "${depends[@]}"
}

function sources_cgenius() {
    gitPullOrClone
}

function _add_games_cgenius(){
    local cmd="$1"
    local dir
    local game
    declare -A games=(
        ['keen1/keen1.exe']="Keen 1: Marooned on Mars (Invasion of the Vorticons)"
        ['keen2/keen2.exe']="Keen 2: The Earth Explodes (Invasion of the Vorticons)"
        ['keen3/keen3.exe']="Keen 3: Keen Must Die! (Invasion of the Vorticons)"
        ['keen3.5/keen3.exe']="Keen Dreams (Lost Episode)"
        ['keen4/keen4.exe']="Keen 4: Secret of the Oracle (Goodbye, Galaxy!)"
        ['keen5/keen5.exe']="Keen 5: The Armageddon Machine (Goodbye, Galaxy!)"
        ['keen6/keen6.exe']="Keen 6: Aliens Ate My Baby Sitter! (Goodbye, Galaxy!)"
    )

    for game in "${!games[@]}"; do
        dir="$romdir/ports/cgenius/$game"
        # Convert Uppercase Filenames to Lowercase
        pushd "${dir%/*}"
        perl-rename 'y/A-Z/a-z/' *
        popd
        if [[ -f "$dir" ]]; then
            addPort "$md_id" "cgenius" "${games[$game]}" "$md_inst/$md_id.sh %ROM%" "dir=games/${game%/*}"
        fi
    done

    if [[ "$md_mode" == "install" ]]; then
        # Create a launcher script to strip quotes from runcommand's generated arguments.
        cat >"$md_inst/$md_id.sh" << _EOF_
#!/bin/bash
$cmd \$*
_EOF_
        chmod +x "$md_inst/$md_id.sh"
    fi
}

function build_cgenius() {
    local params
    if isPlatform x11; then
        params+=("-DUSE_OPENGL=ON")
    fi 
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DNOTYPESAVE=ON \
        -DBUILD_COSMOS=1 \
        "${params[*]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/src/CGeniusExe"
}

function install_cgenius() {
    md_ret_files=(
        'build/src/CGeniusExe'
        'vfsroot'
    )
}

function configure_cgenius() {
    mkRomDir "ports/$md_id"

    moveConfigDir "$home/.CommanderGenius" "$md_conf_root/$md_id"
    moveConfigDir "$md_conf_root/$md_id/games" "$romdir/ports/$md_id"

    [[ "$md_mode" == "install" ]] && _add_games_cgenius "$md_inst/CGeniusExe"
}
