#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="xash3d-fwgs"
rp_module_desc="Xash3D FWGS: Half-Life Source Engine Port"
rp_module_help="Copy Half-Life Data From Folders valve, bshift & gearbox To: ${romdir}/ports/halflife"
rp_module_licence="NONCOM https://raw.githubusercontent.com/FWGS/hlsdk-portable/master/LICENSE"
rp_module_repo=":_pkg_info_xash3d-fwgs"
rp_module_section="exp"
rp_module_flags=""

function depends_xash3d-fwgs() {
    local depends=(
        'freetype2'
        'python'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function _get_repos_xash3d-fwgs() {
    local repos=(
        'fwgs xash3d-fwgs    master'
        'fwgs hlsdk-portable master'
        'fwgs hlsdk-portable bshift'
        'fwgs hlsdk-portable opfor'
    )

    local repo
    for repo in "${repos[@]}"; do
        echo "${repo}"
    done
}

function _pkg_info_xash3d-fwgs() {
    local mode="${1}"
    local repo
    case "${mode}" in
        get)
            local hashes=()
            local hash
            local date
            local newest_date
            while read -r repo; do
                repo=(${repo}) # Do Not Quote
                date=$(git -C "${md_build}/${repo[1]}" log -1 --format=%aI)
                hash="$(git -C "${md_build}/${repo[1]}" log -1 --format=%H)"
                hashes+=("${hash}")
                if rp_dateIsNewer "${newest_date}" "${date}"; then
                    newest_date="${date}"
                fi
            done < <(_get_repos_xash3d-fwgs)
            # Store An 'md5sum' Of The Last Commit Hashes, Used To Check For Changes
            local hash
            hash="$(echo "${hashes[@]}" | md5sum | cut -d" " -f1)"
            echo "local pkg_repo_date=\"${newest_date}\""
            echo "local pkg_repo_extra=\"${hash}\""
            ;;
        newer)
            local hashes=()
            local hash
            while read -r repo; do
                repo=(${repo}) # Do Not Quote
                if ! hash="$(rp_getRemoteRepoHash git https://github.com/${repo[0]}/${repo[1]} ${repo[2]})"; then
                    __ERRMSGS+=("${hash}")
                    return 3
                fi
                hashes+=("${hash}")
            done < <(_get_repos_xash3d-fwgs)
            # Store An 'md5sum' Of The Last Commit Hashes, Used To Check For Changes
            local hash
            hash="$(echo "${hashes[@]}" | md5sum | cut -d" " -f1)"
            if [[ "${hash}" != "${pkg_repo_extra}" ]]; then
                return 0
            fi
            return 1
            ;;
        check)
            local ret=0
            while read -r repo; do
                repo=($repo) # Do Not Quote
                out=$(rp_getRemoteRepoHash git https://github.com/${repo[0]}/${repo[1]} ${repo[2]})
                if [[ -z "$out" ]]; then
                    printMsgs "console" "${id} Repository Failed: https://github.com/${repo[0]}/${repo[1]} ${repo[2]}"
                    ret=1
                fi
            done < <(_get_repos_xash3d-fwgs)
            return "${ret}"
            ;;
    esac
}

function sources_xash3d-fwgs() {
    local repo
    while read -r repo; do
        repo=(${repo}) # Do not quote
        if [[ "${repo[2]}" == "bshift" ]] || [[ "${repo[2]}" == "opfor" ]]; then
            gitPullOrClone "${md_build}/${repo[2]}" https://github.com/${repo[0]}/${repo[1]} ${repo[2]}
        else
            gitPullOrClone "${md_build}/${repo[1]}" https://github.com/${repo[0]}/${repo[1]} ${repo[2]}
        fi
    done < <(_get_repos_xash3d-fwgs)
}

function build_xash3d-fwgs() {
    local dir
    local params=()

    local dirs=(
        'bshift'
        'hlsdk-portable'
        'opfor'
        'xash3d-fwgs'
    )

    for dir in "${dirs[@]}"; do
        cd "${md_build}/${dir}" || exit
        params=(
            '--build-type=release'
            '--enable-lto'
            '--enable-poly-opt'
            '--out=build'
        )
        isPlatform "64bit" && params+=('--64bits')

        [[ "${dir}" == "xash3d-fwgs" ]] && params+=('--enable-packaging' '--disable-vgui' '--disable-menu-changegame')

        ./waf configure --prefix="${md_inst}" "${params[@]}"
        ./waf build
    done

    md_ret_require=("${md_build}/${md_id}/build/game_launch/xash3d")
}

function install_xash3d-fwgs() {
    md_ret_files=(
        "${md_id}/build/game_launch/xash3d"
        "${md_id}/build/engine/libxash.so"
        "${md_id}/build/3rdparty/mainui/libmenu.so"
        "${md_id}/build/ref/soft/libref_soft.so"
        "${md_id}/build/ref/gl/libref_gl.so"
        "${md_id}/build/filesystem/filesystem_stdio.so"
        "${md_id}/build/3rdparty/extras/extras.pk3"
    )

    # Install Library Files From HLSDK
    local dir

    local -A folders=(
        ['bshift']="bshift"
        ['hlsdk-portable']="valve"
        ['opfor']="gearbox"
    )

    for dir in "${!folders[@]}"; do
        mkdir -p "${md_inst}/${folders[${dir}]}"/{cl_dlls,dlls}
        cd "${md_build}/${dir}/build" || exit
        install -Dm644 cl_dll/*.so -t "${md_inst}/${folders[${dir}]}/cl_dlls"
        install -Dm644 dlls/*.so -t "${md_inst}/${folders[${dir}]}/dlls"
    done
}

function _add_games_xash3d-fwgs() {
    local cmd="${1}"
    local dir
    local game
    local portname

    declare -A games=(
        ['valve/halflife.wad']="Half-Life"
        ['bshift/halflife.wad']="Half-Life: Blue Shift"
        ['gearbox/halflife.wad']="Half-Life: Opposing Force"
    )

    for game in "${!games[@]}"; do
        portname="halflife"
        dir="${romdir}/ports/${portname}/${game%%/*}"
        # Convert Uppercase Filenames To Lowercase
        [[ "${md_mode}" == "install" ]] && changeFileCase "${dir}"
        # Create Launch Scripts For Each Game Found
        if [[ -f "${dir}/${game##*/}" ]]; then
            addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${game%%/*}"
        fi
    done
}

function configure_xash3d-fwgs() {
    local portname
    portname="halflife"

    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'bshift'
            'gearbox'
            'valve'
        )
        mkRomDir "ports/${portname}"
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${portname}/${dir}"
            cp -R "${md_inst}/${dir}"/{cl_dlls,dlls} "${romdir}/ports/${portname}/${dir}"
            cp "${md_inst}/extras.pk3" "${romdir}/ports/${portname}/${dir}"
            chown -R "${__user}":"${__group}" "${romdir}/ports/${portname}/${dir}"
        done
    fi

    local launcher_prefix="XASH3D_BASEDIR=${romdir}/ports/${portname}"
    _add_games_xash3d-fwgs "${launcher_prefix} ${md_inst}/xash3d -fullscreen -game %ROM%"
}
