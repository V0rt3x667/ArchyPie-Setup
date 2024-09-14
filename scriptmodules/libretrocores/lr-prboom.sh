#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-prboom"
rp_module_desc="PrBoom (Doom, Doom II, Final Doom & Doom IWAD Mods) Libretro Core"
rp_module_help="ROM Extensions: .iwad .pwad .wad\n\nCopy Doom Files To: ${romdir}/ports/doom/doom1\n\nCopy Doom 2 Files To: ${romdir}/ports/doom/doom2\n\nCopy Final Doom Files To: ${romdir}/ports/doom/finaldoom"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-prboom/master/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-prboom master"
rp_module_section="opt"

function sources_lr-prboom() {
    gitPullOrClone
}

function build_lr-prboom() {
    make clean
    make
    md_ret_require="${md_build}/prboom_libretro.so"
}

function install_lr-prboom() {
    md_ret_files=(
        'prboom_libretro.so'
        'prboom.wad'
    )
}

function _game_data_lr-prboom() {
    local dest="${romdir}/ports/doom"
    local file

    # Download DOOM Shareware If No WAD Exists In The ROM Directory
    for file in "${dest}/doom1/"*.*; do
        if [[ -e "${file}" ]]; then
            break
        else
            download "${__archive_url}/doom1.wad" "${dest}/doom1/doom1.wad"
        fi
    done

    # Download The Latest Version Of Freedoom
    local tag
    tag="$(download "https://api.github.com/repos/freedoom/freedoom/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4)"

    downloadAndExtract "https://github.com/freedoom/freedoom/releases/download/${tag}/freedoom-${tag/v/}.zip" "${dest}/freedoom" -j -LL

    chown -R "${__user}":"${__group}" "${dest}"
}

function _add_games_lr-prboom() {
    local cmd="${1}"
    local dir
    local doomwad
    local game
    local portname
    local wad

    declare -A games=(
        ['doom1/doom.wad']="Doom: The Ultimate Doom"
        ['doom1/doom1.wad']="Doom (Shareware)"
        ['doom1/doomu.wad']="Doom: The Ultimate Doom"
        ['doom2/doom2.wad']="Doom II: Hell on Earth"
        ['finaldoom/plutonia.wad']="Final Doom: The Plutonia Experiment"
        ['finaldoom/tnt.wad']="Final Doom: TNT: Evilution"
        ['freedoom/freedoom1.wad']="Freedoom: Phase I"
        ['freedoom/freedoom2.wad']="Freedoom: Phase II"
    )

    # Add Games That Currently Only Work On GZDoom Or DSDA-Doom
    if [[ "${md_id}" =~ "doom" ]]; then
        games+=(
            ['addons/hell/htp-raw.wad']="Doom II: Hell to Pay"
            ['addons/lost/jptr.wad']="Doom: The Lost Episodes of Doom"
            ['addons/masterlevels/masterlevels.wad']="Doom II: Master Levels"
            ['addons/nerve/nerve.wad']="Doom II: No Rest for the Living"
            ['addons/perdition/pg-raw.wad']="Doom II: Perdition's Gate"
            ['addons/sigil/sigil.wad']="Doom: SIGIL"
            ['addons/sigil/sigil2.wad']="Doom: SIGIL II"
            ['addons/strain/strainfix.wad']="Doom II: Strain"
            ['chex/chex.wad']="Chex Quest"
            ['chex/chex2.wad']="Chex Quest 2"
            ['hacx/hacx.wad']="HacX"
            ['heretic/heretic.wad']="Heretic: Shadow of the Serpent Riders"
            ['heretic/hexen.wad']="Hexen: Beyond Heretic"
        )
    fi

    # Add Games That Currently Only Work On GZDoom
    if [[ "${md_id}" == "gzdoom" ]]; then
        games+=(
            ['addons/bloom/bloom.pk3']="Doom II: Bloom"
            ['addons/brutal/brutal.pk3']="Doom: Brutal Doom"
            ['addons/brutal/brutality.pk3']="Doom: Project Brutality"
            ['addons/brutal/brutalwolf.pk3']="Doom: Brutal Wolfenstein"
            ['chex/chex3.wad']="Chex Quest 3"
            ['heretic/hexdd.wad']="Hexen: Deathkings of the Dark Citadel"
            ['square/square1.pk3']="The Adventures of Square"
            ['strife/strife1.wad']="Strife: Quest for the Sigil"
            ['urban/action2.wad']="Urban Brawl: Action Doom 2"
            ['wboa/boa.ipk3']="Wolfenstein: Blade of Agony"
        )
    fi

    # Check Which WAD To Use For Doom Ultimate
    if [[ -f "${romdir}/ports/${portname}/doom1/doomu.wad" ]]; then
        doomwad="doomu.wad"
    else
        doomwad="doom.wad"
    fi

    for game in "${!games[@]}"; do
        portname="doom"
        dir="${romdir}/ports/${portname}/${game%%/*}"
        wad="${romdir}/ports/${portname}/${game}"
        # Convert Uppercase Filenames To Lowercase
        [[ "${md_mode}" == "install" ]] && changeFileCase "${dir}"
        # Create Launch Scripts For Each Game Found
        if [[ -f "${wad}" ]]; then
            # Add Games Which Do Not Require Additional Parameters
            addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${wad}"
            if [[ "${md_id}" =~ "doom" ]]; then
                # Add SIGIL (Buckethead Soundtrack)
                if [[ "${game##*/}" == "sigil.wad" ]] && [[ -f "${dir}/sigil/sigil_shreds.wad" ]]; then
                    wad="${romdir}/ports/${portname}/doom1/${doomwad} -file ${romdir}/ports/${portname}/${game} ${romdir}/ports/${portname}/addons/sigil/sigil_shreds.wad"
                    addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${wad}"
                # Add SIGIL (MIDI Soundtrack)
                elif [[ "${game##*/}" == "sigil.wad" ]] && [[ ! -f "${dir}/sigil/sigil_shreds.wad" ]]; then
                    wad="${romdir}/ports/${portname}/doom1/${doomwad} -file ${romdir}/ports/${portname}/${game}"
                    addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${wad}"
                # Add SIGIL II (Thorr Soundtrack)
                elif [[ "${game##*/}" == "sigil2.wad" ]] && [[ -f "${dir}/sigil/sigil2_mp3.wad" ]]; then
                    wad="${romdir}/ports/${portname}/doom1/${doomwad} -file ${romdir}/ports/${portname}/${game} ${romdir}/ports/${portname}/addons/sigil/sigil2_mp3.wad"
                    addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${wad}"
                # Add SIGIL II (MIDI Soundtrack)
                elif [[ "${game##*/}" == "sigil2.wad" ]] && [[ ! -f "${dir}/sigil/sigil2_mp3.wad" ]]; then
                    wad="${romdir}/ports/${portname}/doom1/${doomwad} -file ${romdir}/ports/${portname}/${game}"
                    addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${wad}"
                # Add Strain
                elif [[ "${game##*/}" == "strainfix.wad" ]]; then
                    wad="${romdir}/ports/${portname}/doom2/doom2.wad -file ${romdir}/ports/${portname}/${game}"
                    addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${wad}"
                # Add Doom II: Master Levels
                elif [[ "${game##*/}" == "masterlevels.wad" ]]; then
                    wad="${romdir}/ports/${portname}/doom2/doom2.wad -file ${romdir}/ports/${portname}/${game}"
                    addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${wad}"
                # Add Doom II: No Rest for the Living
                elif [[ "${game##*/}" == "nerve.wad" ]]; then
                    wad="${romdir}/ports/${portname}/doom2/doom2.wad -file ${romdir}/ports/${portname}/${game}"
                    addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${wad}"
                # Add Doom II: Hell to Pay
                elif [[ "${game##*/}" == "htp-raw.wad" ]]; then
                    wad="${romdir}/ports/${portname}/doom2/doom2.wad -file ${romdir}/ports/${portname}/${game}"
                    addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${wad}"
                # Add Doom II: Perdition's Gate
                elif [[ "${game##*/}" == "pg-raw.wad" ]]; then
                    wad="${romdir}/ports/${portname}/doom2/doom2.wad -file ${romdir}/ports/${portname}/${game}"
                    addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${wad}"
                # Add Doom: The Lost Episodes of Doom
                elif [[ "${game##*/}" == "jptr.wad" ]]; then
                    wad="${romdir}/ports/${portname}/doom1/${doomwad} -file ${romdir}/ports/${portname}/${game}"
                    addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${wad}"
                fi
            fi

            # Add Games & Options That Only Work On GZDoom
            if [[ "${md_id}" == "gzdoom" ]]; then
                # Add Bloom
                if [[ "${game##*/}" == "bloom.pk3" ]]; then
                    wad="${romdir}/ports/${portname}/doom2/doom2.wad -file ${romdir}/ports/${portname}/${game}"
                    addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${wad}"
                # Add Project Brutality & Other "Brutality" Mods If Available
                elif [[ "${game##*/}" =~ "brutal" ]]; then
                    wad="* -file ${romdir}/ports/${portname}/${game}"
                    addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${wad}"
                fi
                # Load Addons From The 'misc' Folder
                addPort "${md_id}-addon" "${portname}" "${games[${game}]}" "${cmd} -file ${romdir}/ports/${portname}/addons/misc/*" "${wad}"
            fi
        fi
    done
}

function configure_lr-prboom() {
    local portname
    portname="doom"

    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'doom1'
            'doom2'
            'finaldoom'
            'freedoom'
        )
        mkRomDir "ports/${portname}"
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${portname}/${dir}"
        done

        # Copy Data File To BIOS Dir
        mkUserDir "${biosdir}/${portname}"
        cp "${md_inst}/prboom.wad" "${biosdir}/${portname}"
        chown -R "${__user}":"${__group}" "${biosdir}/${portname}"

        # Add Shareware Game Data If No Existing WAD Is Found & Add Freedoom
        _game_data_lr-prboom
    fi

    setConfigRoot "ports"

    defaultRAConfig "${portname}"

    _add_games_lr-prboom "${md_inst}/prboom_libretro.so"
}
