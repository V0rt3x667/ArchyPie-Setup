#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dhewm3"
rp_module_desc="dhewm3: DOOM3 Port"
rp_module_licence="GPL3 https://raw.githubusercontent.com/dhewm/dhewm3/master/COPYING.txt"
rp_module_repo="git https://github.com/dhewm/dhewm3 :_get_branch_dhewm3"
rp_module_section="opt"
rp_module_flags="!all 64bit"

function _get_branch_dhewm3() {
    download "https://api.github.com/repos/dhewm/dhewm3/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_dhewm3() {
    local depends=(
        'clang'
        'cmake'
        'curl'
        'libjpeg'
        'libvorbis'
        'lld'
        'ninja'
        'openal'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_dhewm3() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|%s/.local/share/${md_id}|%s/ArchyPie/configs/${md_id}|g" -i "${md_build}/neo/sys/linux/main.cpp"
    sed -e "s|%s/.config/${md_id}|%s/ArchyPie/configs/${md_id}|g" -i "${md_build}/neo/sys/linux/main.cpp"
}

function build_dhewm3() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -S"neo" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DLINUX_RELEASE_BINS="ON" \
        -DREPRODUCIBLE_BUILD="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_dhewm3() {
    ninja -C build install/strip
}

function _game_data_dhewm3() {
    local url
    local portname

    portname="doom3"
    url="https://files.holarse-linuxgaming.de/native/Spiele/Doom%203/Demo/${portname}-linux-1.1.1286-demo.x86.run"

    if [[ ! -f "${romdir}/ports/${portname}/base/pak000.pk4" ]] && [[ ! -f "${romdir}/ports/${portname}/demo/demo00.pk4" ]]; then
        download "${url}" "${romdir}/ports/${portname}"
        chmod +x "${romdir}/ports/${portname}/${portname}-linux-1.1.1286-demo.x86.run"
        cd "${romdir}/ports/${portname}" || return
        ./${portname}-linux-1.1.1286-demo.x86.run --tar xf demo/ && rm "${romdir}/ports/${portname}/${portname}-linux-1.1.1286-demo.x86.run"
        chown -R "${user}:${user}" "${romdir}/ports/${portname}/demo"
    fi
}

function _add_games_dhewm3() {
    local cmd="${1}"
    local dir
    local game
    local portname

    declare -A games=(
        ['base/pak000.pk4']="Doom3"
        ['demo/demo00.pk4']="Doom3 (Demo)"
        ['d3xp/pak000.pk4']="Doom3: Resurrection of Evil"
    )

    for game in "${!games[@]}"; do
        portname="doom3"
        dir="${romdir}/ports/${portname}/${game%%/*}"
        # Convert Uppercase Filenames To Lowercase
        [[ "${md_mode}" == "install" ]] && changeFileCase "${dir}"
        # Create Launch Scripts For Each Game Found
        if [[ -f "${dir}/${game##*/}" ]]; then
            addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${game%%/*}"
        fi
    done
}

function configure_dhewm3() {
    local portname
    portname="doom3"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'base'
            'd3xp'
        )
        mkRomDir "ports/${portname}"
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${portname}/${dir}"
        done

        _game_data_dhewm3
    fi

    local basedir="${romdir}/ports/${portname}"
    _add_games_dhewm3 "${md_inst}/bin/${md_id} +set fs_basepath ${basedir} +set r_fullscreen 1 +set fs_game %ROM%"
}
