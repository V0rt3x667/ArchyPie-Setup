#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="jumpnbump"
rp_module_desc="Jump 'n Bump: Play Cute Bunnies Jumping On Each Other's Heads"
rp_module_help="Copy Custom Game Levels (.dat) To: ${romdir}/ports/jumpnbump"
rp_module_licence="GPL2 https://gitlab.com/LibreGames/jumpnbump/raw/master/COPYING"
rp_module_repo="git https://gitlab.com/LibreGames/jumpnbump master"
rp_module_section="exp"
rp_module_flags=""

function depends_jumpnbump() {
    local depends=(
        'sdl2_mixer'
        'sdl2_net'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_jumpnbump() {
    gitPullOrClone
}

function build_jumpnbump() {
    make clean
    CFLAGS="$CFLAGS -fsigned-char" make PREFIX="${md_inst}"
    md_ret_require="${md_build}/${md_id}"
}

function install_jumpnbump() {
    make PREFIX="${md_inst}" install
    strip "${md_inst}"/bin/{gobpack,jnbpack,jnbunpack,jumpnbump}
}

function _game_data_jumpnbump() {
    local compressed
    local dest
    local uncompressed

    dest="${__tmpdir}/archives"

    # Install Extra Levels From Debian's jumpnbump-levels Package
    downloadAndExtract "https://salsa.debian.org/games-team/${md_id}-levels/-/archive/master/${md_id}-levels-master.tar.bz2" "${dest}" --strip-components 1 --wildcards "*.bz2"
    for compressed in "${dest}"/*.bz2; do
        uncompressed="${compressed##*/}"
        uncompressed="${uncompressed%.bz2}"
        if [[ ! -f "${romdir}/ports/${md_id}/${uncompressed}" ]]; then
            bzcat "${compressed}" > "${romdir}/ports/${md_id}/${uncompressed}"
            chown -R "${user}:${user}" "${romdir}/ports/${md_id}/${uncompressed}"
        fi
    done
    rm -rf "${dest}"
}

function configure_jumpnbump() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ports/${md_id}"

        _game_data_jumpnbump

        # Install Launch Script
        cp "${md_data}/${md_id}.sh" "${md_inst}"
        iniConfig "=" '"' "${md_inst}/${md_id}.sh"
        iniSet "ROOTDIR" "${rootdir}"
        iniSet "MD_CONF_ROOT" "${md_conf_root}"
        iniSet "ROMDIR" "${romdir}"
        iniSet "MD_INST" "${md_inst}"

        # Set Default Game Options On First Install
        if [[ ! -f "${md_conf_root}/${md_id}/options.cfg" ]];  then
            iniConfig " = " "" "${md_conf_root}/${md_id}/options.cfg"
            iniSet "nogore" "1"
        fi
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addPort "${md_id}" "${md_id}" "Jump 'n Bump" "${md_inst}/${md_id}.sh"
}
