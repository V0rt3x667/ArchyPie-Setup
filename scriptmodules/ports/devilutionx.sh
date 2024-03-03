#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="devilutionx"
rp_module_desc="DevilutionX: Diablo & Diablo: Hellfire Port"
rp_module_licence="NONCOM https://raw.githubusercontent.com/diasurgical/devilutionX/master/LICENSE"
rp_module_repo="git https://github.com/diasurgical/devilutionX :_get_branch_devilutionx"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_devilutionx() {
    download "https://api.github.com/repos/diasurgical/devilutionx/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_devilutionx() {
    local depends=(
        'bzip2'
        'clang'
        'cmake'
        'fmt'
        'gettext'
        'libpng'
        'libsodium'
        'lld'
        'ninja'
        'sdl2_mixer'
        'sdl2_ttf'
        'sdl2'
        'zlib'
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
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DBUILD_TESTING="OFF" \
        -DDEVILUTIONX_SYSTEM_LIBFMT="ON" \
        -DDEVILUTIONX_SYSTEM_LIBSODIUM="ON" \
        -DPIE="ON" \
        -DVERSION_NUM="${ver}" \
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
    local cmd="${1}"
    local dir
    local game
    local portname

    declare -A games=(
        ['diabdat.mpq']="Diablo"
        ['hellfire.mpq']="Diablo: Hellfire"
        ['spawn.mpq']="Diablo: Spawn (Shareware)"
    )

    for game in "${!games[@]}"; do
        portname="diablo"
        dir="${romdir}/ports/${portname}"
        # Convert Uppercase Filenames To Lowercase
        [[ "${md_mode}" == "install" ]] && changeFileCase "${dir}"
        # Create Launch Scripts For Each Game Found
        if [[ -f "${dir}/${game}" ]]; then
            if [[ "${game}" == "diabdat.mpq" ]]; then
                addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd} --%ROM%" "diablo"
            else
                addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd} --%ROM%" "${game%%.*}"
            fi
        fi
    done
}

function configure_devilutionx() {
    local portname
    portname="diablo"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/"

    [[ "${md_mode}" == "install" ]] && mkRomDir "ports/${portname}"

    local params=(
        "--config-dir ${arpdir}/${md_id}"
        "--save-dir ${romdir}/ports/${portname}"
        "--data-dir ${md_inst}/ports/${md_id}/assets/"
    )
    _add_games_devilutionx "${md_inst}/${md_id} ${params[*]}"
}
