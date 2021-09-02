#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="yquake2"
rp_module_desc="Yamagi Quake II - Quake II Client Including Ground Zero, The Reckoning & Capture The Flag"
rp_module_licence="GPL2 https://raw.githubusercontent.com/yquake2/yquake2/master/LICENSE"
rp_module_repo="git https://github.com/yquake2/yquake2.git :_get_branch_yquake2"
rp_module_section="exp"
rp_module_flags=""

function _get_branch_yquake2() {
    download https://api.github.com/repos/yquake2/yquake2/tags - | grep -m 1 name | cut -d\" -f4
}

function depends_yquake2() {
    local depends=(
        'glu'
        'libglvnd'
        'libogg'
        'libvorbis'
        'openal'
        'openssl'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_yquake2() {
    gitPullOrClone
    local url="https://github.com/yquake2"
    local repo=(
        'ctf'
        'rogue'
        'xatrix'
    )
    for r in "${repo[@]}"; do
        gitPullOrClone "$md_build/$r" "$url/$r"
    done
}

function build_yquake2() {
    cmake . \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_TYPE=Release \
        -DSYSTEMWIDE_SUPPORT=OFF
    make clean
    make

    local dir=(
        'ctf'
        'rogue'
        'xatrix'
    )
    for d in "${dir[@]}"; do
        cd "$md_build/$d"
        make clean
        make
    done
    md_ret_require="$md_build/release/quake2"
}

function install_yquake2() {
    md_ret_files=(
        'release/baseq2'
        'release/q2ded'
        'release/quake2'
        'release/ref_gl1.so'
        'release/ref_gl3.so'
        'release/ref_soft.so'
        'LICENSE'
        'README.md'
    )
    local dir=(
        'ctf'
        'rogue'
        'xatrix'
    )
    for d in "${dir[@]}"; do
         mkdir "$md_inst/$d"
         cd "$md_build/$d/release"
         cp game.so "$md_inst/$d" 
    done
}

function add_games_yquake2() {
    local cmd="$1"
    declare -A games=(
        ['baseq2/pak0']="Quake II"
        ['xatrix/pak0']="Quake II - Mission Pack 1 - The Reckoning"
        ['rogue/pak0']="Quake II - Mission Pack 2 - Ground Zero"
        ['ctf/pak0']="Quake II - Third Wave Capture The Flag"
    )

    local game
    local pak="$romdir/ports/quake2/$game.pak"
    for game in "${!games[@]}"; do
        if [[ -f "$pak" ]]; then
            addPort "$md_id" "quake2" "${games[$game]}" "$cmd" "${game%%/*}"
        fi
    done
}

function game_data_yquake2() {
    local unwanted

    if [[ ! -f "$romdir/ports/quake2/baseq2/pak1.pak" && ! -f "$romdir/ports/quake2/baseq2/pak0.pak" ]]; then
        # get shareware game data
        downloadAndExtract "https://deponie.yamagi.org/quake2/idstuff/q2-314-demo-x86.exe" "$romdir/ports/quake2/baseq2" -j -LL
    fi

    # remove files that are likely to cause conflicts or unwanted default settings
    for unwanted in $(find "$romdir/ports/quake2" -maxdepth 2 -name "*.so" -o -name "*.cfg" -o -name "*.dll" -o -name "*.exe"); do
        rm -f "$unwanted"
    done

    chown -R $user:$user "$romdir/ports/quake2"
}


function configure_yquake2() {
    local params=()

    if isPlatform "gles3"; then
        params+=("+set vid_renderer gl3")
    elif isPlatform "gl" || isPlatform "mesa"; then
        params+=("+set vid_renderer gl1")
    else
        params+=("+set vid_renderer soft")
    fi

    if isPlatform "kms"; then
        params+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%" "+set r_vsync 1")
    fi

    mkRomDir "ports/quake2"
    
    moveConfigDir "$home/.yq2" "$md_conf_root/quake2/yquake2"
    chown -R "$user:$user" "$md_conf_root/quake2"

    [[ "$md_mode" == "install" ]] && game_data_yquake2
    add_games_yquake2 "$md_inst/quake2 -datadir $romdir/ports/quake2 ${params[*]} +set game %ROM%"
}
