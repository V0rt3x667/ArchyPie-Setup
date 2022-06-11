#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-prboom"
rp_module_desc="PrBoom (Doom, Doom II, Final Doom & Doom IWAD Mods) Libretro Core"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-prboom/master/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-prboom.git master"
rp_module_section="opt"

function sources_lr-prboom() {
    gitPullOrClone
}

function build_lr-prboom() {
    make clean
    make
    md_ret_require="$md_build/prboom_libretro.so"
}

function install_lr-prboom() {
    md_ret_files=(
        'prboom_libretro.so'
        'prboom.wad'
    )
}

function _game_data_lr-prboom() {
    local dest="$romdir/ports/doom"

    if [[ ! -f "$dest/doom1.wad" ]]; then
        # Download DOOM 1 shareware.
        download "$__archive_url/doom1.wad" "$dest/doom1.wad"
    fi
    if ! echo "e9bf428b73a04423ea7a0e9f4408f71df85ab175 $dest/freedoom1.wad" | sha1sum -c &>/dev/null; then
        # Download or update Freedoom
        downloadAndExtract "https://github.com/freedoom/freedoom/releases/download/v0.12.1/freedoom-0.12.1.zip" "$dest" -j -LL
    fi
    chown -R "$user:$user" "$dest"
}

function _add_games_lr-prboom() {
    local addon="$romdir/ports/doom/addon"
    local cmd="$1"
    local doswad
    local game
    local wad
    declare -A games=(
        ['doom1.wad']="Doom (Shareware)"
        ['doom.wad']="Doom: The Ultimate Doom"
        ['doomu.wad']="Doom: The Ultimate Doom"
        ['doom2.wad']="Doom II: Hell on Earth"
        ['masterlevels.wad']="Doom II: Master Levels"
        ['tnt.wad']="Final Doom: TNT: Evilution"
        ['plutonia.wad']="Final Doom: The Plutonia Experiment"
        ['freedoom1.wad']="Freedoom: Phase I"
        ['freedoom2.wad']="Freedoom: Phase II"
    )
    if [[ "$md_id" == "gzdoom" || "$md_id" == "lzdoom" ]]; then
        games+=(
            ['chex.wad']="Chex Quest"
            ['chex2.wad']="Chex Quest 2"
            ['chex3.wad']="Chex Quest 3"
            ['hacx.wad']="HacX"
            ['heretic.wad']="Heretic: Shadow of the Serpent Riders"
            ['hexdd.wad']="Hexen: Deathkings of the Dark Citadel"
            ['hexen.wad']="Hexen: Beyond Heretic"
            ['strife1.wad']="Strife"
        )
    fi
    # Create .sh files for each game found. Uppercase filnames will be converted to lowercase.
    for game in "${!games[@]}"; do
        doswad="$romdir/ports/doom/${game^^}"
        wad="$romdir/ports/doom/$game"
        if [[ -f "$doswad" ]]; then
            mv "$doswad" "$wad"
        fi
        if [[ -f "$wad" ]]; then
            addPort "$md_id" "doom" "${games[$game]}" "$cmd" "$wad"
            if [[ "$md_id" == "gzdoom" || "$md_id" == "lzdoom" ]]; then
                addPort "$md_id-addon" "doom" "${games[$game]}" "$cmd -file ${addon}/*" "$wad"
            fi
        fi
    done
}

function configure_lr-prboom() {
    setConfigRoot "ports"

    mkRomDir "ports/doom"
    mkRomDir "ports/doom/addon"

    defaultRAConfig "doom"

    [[ "$md_mode" == "install" ]] && _game_data_lr-prboom

    _add_games_lr-prboom "$md_inst/prboom_libretro.so"
}
