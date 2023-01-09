#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="devilutionx"
rp_module_desc="DevilutionX: Diablo & Diablo: Hellfire Port"
rp_module_licence="TU https://raw.githubusercontent.com/diasurgical/devilutionX/master/LICENSE"
rp_module_repo="git https://github.com/diasurgical/devilutionX.git :_get_branch_devilutionx"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_devilutionx() {
    download "https://api.github.com/repos/diasurgical/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_devilutionx() {
    local depends=(
        'cmake'
        'fmt'
        'gettext'
        'libpng'
        'libsodium'
        'ninja'
        'perl-rename'
        'sdl2_mixer'
        'sdl2_ttf'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_devilutionx() {
    gitPullOrClone
}

function build_devilutionx() {
    local ver
    ver="$(_get_branch_devilutionx)"
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DVERSION_NUM="${ver}" \
        -DDEVILUTIONX_SYSTEM_LIBFMT="ON" \
        -DDEVILUTIONX_SYSTEM_LIBSODIUM="ON" \
        -DBUILD_TESTING="OFF" \
        -DPIE="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_devilutionx() {
    md_ret_files=(
        'build/devilutionx'
        'Packaging/nix/README.txt'
        'Packaging/resources/assets/'
    )
}

function _add_games_devilutionx() {
    local cmd="$1"
    local dir
    local game
    local portname

    declare -A games=(
        ['diabdat.mpq']="Diablo"
        ['hellfire.mpq']="Diablo: Hellfire"
        ['spawn.mpq']="Diablo: Spawn (Shareware)"
    )

    # Create .sh Files For Each Game Found. Uppercase Filenames Will Be Converted to Lowercase.
    for game in "${!games[@]}"; do
        portname="diablo"
        dir="${romdir}/ports/${portname}"
        if [[ "${md_mode}" == "install" ]]; then
            pushd "${dir}" || return
            perl-rename 'y/A-Z/a-z/' [^.-]{*,*/*}
            popd || return
        fi
        if [[ -f "${dir}/${game}" ]]; then
            if [[ "${game}" == "diabdat.mpq" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "${cmd} --%ROM%" "diablo"
            elif [[ "${game}" == "hellfire.mpq" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "${cmd} --%ROM%" "hellfire"
            else
                addPort "${md_id}" "${portname}" "${games[$game]}" "${cmd} --%ROM%" "spawn"
            fi
        fi
    done
}

function configure_devilutionx() {
    local portname
    portname="diablo"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ports/${portname}"
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/"

    local params=(
        "--config-dir ${arpdir}/${md_id}"
        "--save-dir ${romdir}/ports/${portname}"
        "--data-dir ${md_inst}/ports/${md_id}/assets/"
    )
    _add_games_devilutionx "${md_inst}/${md_id} ${params[*]}"
}
