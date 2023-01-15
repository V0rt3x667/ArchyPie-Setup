#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="frotz"
rp_module_desc="Frotz: Interpreter For Infocom & Z-Machine Games"
rp_module_help="ROM Extensions: .dat .z1 .z2 .z3 .z4 .z5 .z6 .z7 .z8 .zip\n\nCopy Infocom Games To: ${romdir}/zmachine"
rp_module_licence="GPL2 https://gitlab.com/DavidGriffith/frotz/raw/master/COPYING"
rp_module_section="opt"
rp_module_repo="git https://gitlab.com/DavidGriffith/frotz :_get_branch_frotz"
rp_module_flags=""

function _get_branch_frotz() {
    download "https://gitlab.com/api/v4/projects/DavidGriffith%2Ffrotz/releases" - | grep -m 1 tag_name | cut -d\" -f8
}

function depends_frotz() {
    local depends=(
        'freetype2'
        'libao'
        'libjpeg-turbo'
        'libmodplug'
        'libpng'
        'libsamplerate'
        'libsndfile'
        'libvorbis'
        'sdl2_mixer'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_frotz() {
    gitPullOrClone
}

function build_frotz() {
    make PREFIX="${md_inst}" SYSCONFDIR="${arpdir}/${md_id}" sdl
    md_ret_require=("${md_build}/sfrotz")
}

function install_frotz() {
    make PREFIX="${md_inst}" install_sdl
    cp "${md_build}/doc/frotz.conf-big" "${md_inst}/share/"
    md_ret_require=("${md_inst}/bin/sfrotz")
}

function _game_data_frotz() {
    local dest="${romdir}/zmachine"
    if [[ ! -f "${dest}/zork1.dat" ]]; then
        mkUserDir "${dest}"
        local temp
        temp="$(mktemp -d)"
        local file
        for file in zork1 zork2 zork3; do
            downloadAndExtract "${__archive_url}/${file}.zip" "${temp}" -L
            cp "${temp}/data/${file}.dat" "${dest}"
            rm -rf "${temp}"
        done
        rm -rf "${temp}"
        chown -R "${user}:${user}" "${romdir}/zmachine"
    fi
}

function configure_frotz() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/zmachine/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "zmachine"
        copyDefaultConfig "${md_inst}/share/${md_id}.conf-big" "${arpdir}/${md_id}/${md_id}.conf"
        _game_data_frotz
    fi

    # CON: Stop 'runcommand' From Redirecting 'stdout' To Log
    addEmulator 1 "${md_id}" "zmachine" "CON:pushd ${romdir}/zmachine; ${md_inst}/bin/sfrotz -F %ROM%; popd"

    addSystem "zmachine"
}
