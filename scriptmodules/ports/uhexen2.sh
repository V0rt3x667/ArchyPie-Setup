#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="uhexen2"
rp_module_desc="Hammer of Thyrion (uHexen2) - Hexen II Source Port"
rp_module_licence="GPL2 https://raw.githubusercontent.com/sezero/uhexen2/master/docs/COPYING"
rp_module_help="Add your PAK files to $romdir/ports/hexen2/data1/ and $romdir/ports/hexen2/portals/ to play. The files for Hexen II are: pak0.pak, pak1.pak and strings.txt. The registered pak files must be patched to 1.11 for Hammer of Thyrion."
rp_module_repo="git https://github.com/sezero/uhexen2.git master"
rp_module_section="opt"
rp_module_flags=""

function depends_uhexen2() {
    local depends=(
        'alsa-lib'
        'libglvnd'
        'flac'
        'libmad' 
        'libogg'
        'libvorbis' 
        'sdl'
    )
    isPlatform x86 && depends+=('yasm')
    getDepends "${depends[@]}"
}

function sources_uhexen2() {
    gitPullOrClone
}

function build_uhexen2() {
    # Build Hexen Game Engine
    cd "$md_build/engine/hexen2" || return
    ./build_all.sh
    # Build HexenWorld
    cd "$md_build/engine/hexenworld" || return
    ./build.sh
    # Build Hexen Utilities
    cd "$md_build" || return
    make -C hw_utils/hwmaster
    make -C h2patch
    make -C utils/hcc
    # Build Game Code Files
    cd "$md_build/gamecode" || return
    "$md_build/utils/hcc/hcc" -src hc/h2 -os
    "$md_build/utils/hcc/hcc" -src hc/h2 -os -name progs2.src
    "$md_build/utils/hcc/hcc" -src hc/portals -os -oi -on
    "$md_build/utils/hcc/hcc" -src hc/hw -os -oi -on
    "$md_build/utils/hcc/hcc" -src hc/siege -os -oi -on

    md_ret_require="$md_build/engine/hexen2/glhexen2"
}

function install_uhexen2() {
    md_ret_files=(
        'engine/hexen2/glhexen2'
        'engine/hexen2/hexen2'
        'engine/hexenworld/client/hwcl'
        'engine/hexenworld/client/glhwcl'
        'engine/hexenworld/server/hwsv'
        'engine/hexen2/server/h2ded'
        'h2patch/h2patch'
        'scripts/'
        'docs/'
        'gamecode/hc/h2'
        'gamecode/hc/portals'
        'gamecode/hc/hw'
        'gamecode/hc/portals'
        'gamecode/mapfixes/data1'
        'gamecode/mapfixes/portals'
        'gamecode/patch111/patchdat'
    )
}

function _add_games_uhexen2() {
    local game
    declare -A games=(
        ['data1/pak0.pak']="Hexen II"
        ['portals/pak3.pak']="Hexen II: Portal of Praevus"
    )

    for game in "${!games[@]}"; do
        local file="$romdir/ports/hexen2/$game"
        if [[ "$game" == portals/pak3.pak && -f "$file" ]]; then
            addPort "$md_id-gl" "hexen2" "${games[$game]}" "$md_inst/glhexen2 -f -vsync -portals" "${game%%/*}"
            addPort "$md_id" "hexen2" "${games[$game]}" "$md_inst/hexen2 -f -vsync -portals" "${game%%/*}"
        elif [[ "$game" == data1/pak0.pak && -f "$file" ]]; then
            addPort "$md_id-gl" "hexen2" "${games[$game]}" "$md_inst/glhexen2 -f -vsync" "${game%%/*}"
            addPort "$md_id" "hexen2" "${games[$game]}" "$md_inst/hexen2 -f -vsync" "${game%%/*}"
        fi
    done
}

function _game_data_uhexen2() {
    if [[ ! -f "$romdir/ports/hexen2/data1/pak0.pak" ]]; then
        downloadAndExtract "http://sourceforge.net/project/downloading.php?group_id=124987&filename=hexen2demo_nov1997-linux-x86_64.tgz" "$romdir/ports/hexen2" --strip-components 1 "hexen2demo_nov1997/data1"
        chown -R "$user:$user" "$romdir/ports/hexen2/data1"
    fi
}

function configure_uhexen2() {
    mkRomDir "ports/hexen2"

    moveConfigDir "$home/.hexen2" "$romdir/ports/hexen2"

    [[ "$md_mode" == "install" ]] && _game_data_uhexen2 && _add_games_uhexen2
}
