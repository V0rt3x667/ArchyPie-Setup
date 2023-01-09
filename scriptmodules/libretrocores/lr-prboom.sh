#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-prboom"
rp_module_desc="PrBoom (Doom, Doom II, Final Doom & Doom IWAD Mods) Libretro Core"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-prboom/master/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-prboom.git master"
rp_module_section="opt"

function depends_lr-prboom() {
    getDepends perl-rename
}

function sources_lr-prboom() {
    gitPullOrClone
}

function build_lr-prboom() {
    make clean
    make
    md_ret_require="${md_build}/prboom_libretro.so"
}

function install_lr-prboom() {
    md_ret_files=('prboom_libretro.so' 'prboom.wad')
}

function _game_data_lr-prboom() {
    local dest="${romdir}/ports/doom"

    if [[ ! -f "${dest}/doom1/doom1.wad" ]] && [[ ! -f "${dest}/doom1/DOOM1.WAD" ]]; then
        # Download DOOM Shareware
        download "${__archive_url}/doom1.wad" "${dest}/doom1/doom1.wad"
    fi
    if ! echo "e9bf428b73a04423ea7a0e9f4408f71df85ab175 ${dest}/freedoom/freedoom1.wad" | sha1sum -c &>/dev/null; then
        # Download or Update Freedoom
        downloadAndExtract "https://github.com/freedoom/freedoom/releases/download/v0.12.1/freedoom-0.12.1.zip" "${dest}/freedoom" -j -LL
    fi
    chown -R "${user}:${user}" "${dest}"
}

function _add_games_lr-prboom() {
    local cmd="$1"
    local dir
    local game
    local portname
    declare -A games=(
        ['doom1/doom.wad']="Doom: The Ultimate Doom"
        ['doom1/doom1.wad']="Doom (Shareware)"
        ['doom1/doomu.wad']="Doom: The Ultimate Doom"
        ['doom2/doom2.wad']="Doom II: Hell on Earth"
        ['doom2/masterlevels.wad']="Doom II: Master Levels"
        ['finaldoom/plutonia.wad']="Final Doom: The Plutonia Experiment"
        ['finaldoom/tnt.wad']="Final Doom: TNT: Evilution"
        ['freedoom/freedoom1.wad']="Freedoom: Phase I"
        ['freedoom/freedoom2.wad']="Freedoom: Phase II"
    )

    # Create .sh Files For Each Game Found. Uppercase Filenames Will Be Converted to Lowercase.
    for game in "${!games[@]}"; do
        portname="doom"
        dir="${romdir}/ports/${portname}/${game%/*}"
        if [[ "${md_mode}" == "install" ]]; then
            pushd "${dir}" || return
            perl-rename 'y/A-Z/a-z/' [^.-]{*,*/*}
            popd || return
        fi
        if [[ -f "${dir}/${game##*/}" ]]; then
            addPort "${md_id}" "${portname}" "${games[$game]}" "${cmd}" "${game##*/}"
        fi
    done
}

function configure_lr-prboom() {
    local portname
    portname="doom"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ports/${portname}"
        mkUserDir "${biosdir}/${portname}"
        cp "${md_inst}/prboom.wad" "${biosdir}/${portname}"
        chown -R "${user}:${user}" "${biosdir}/${portname}"
        _game_data_lr-prboom
    fi

    setConfigRoot "ports"

    defaultRAConfig "${portname}" "system_directory" "${biosdir}/${portname}"

    _add_games_lr-prboom "${md_inst}/prboom_libretro.so"
}
