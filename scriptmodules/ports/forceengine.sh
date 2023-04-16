#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="forceengine"
rp_module_desc="The Force Engine: Dark Forces & Outlaws Port"
rp_module_licence="GPL2 https://raw.githubusercontent.com/luciusDXL/TheForceEngine/master/LICENSE"
rp_module_repo="git https://github.com/luciusDXL/TheForceEngine :_get_branch_forceengine"
rp_module_section="exp"
rp_module_flags=""

function _get_branch_forceengine() {
    download "https://api.github.com/repos/luciusDXL/TheForceEngine/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_forceengine() {
    local depends=(
        'cmake'
        'devil'
        'glew'
        'mesa'
        'ninja'
        'rtaudio'
        'rtmidi'
        'sdl2'
        'zenity'
    )
    getDepends "${depends[@]}"
}

function sources_forceengine() {
    gitPullOrClone
}

function build_forceengine() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/theforceengine"
}

function install_forceengine() {
    ninja -C build install/strip
}

function _add_games_forceengine() {
    local cmd="$1"
    local dir
    local game
    local portname

    declare -A games=(
        ['darkforces/dark.gob']="Dark Forces"
        ['outlaws/outlaws.lab']="Outlaws" # To Be Added In A Future Release
    )

    # Create .sh Files For Each Game Found. Uppercase Filenames Will Be Converted to Lowercase
    for game in "${!games[@]}"; do
        portname="forceengine"
        dir="${romdir}/ports/${portname}"
        if [[ "${md_mode}" == "install" ]]; then
            pushd "${dir}/${game%%/*}" || return
            perl-rename 'y/A-Z/a-z/' [^.-] {*,*/*}
            popd || return
        fi
        if [[ -f "${dir}/${game}" ]]; then
            addPort "${md_id}" "${portname}" "${games[$game]}" "${cmd}" "${game%%/*}"
        fi
    done
}

function configure_forceengine() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'darkforces'
            'outlaws'
        )
        mkRomDir "ports/${md_id}"
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${md_id}/${dir}"
        done

        # Create Default Configuration File
        local config
        config="$(mktemp)"

        cat > "${config}" << _INI_
[Window]
fullscreen=true
[Dark_Forces]
sourcePath="${romdir}/ports/${md_id}/darkforces"
[Outlaws]
sourcePath="${romdir}/ports/${md_id}/outlaws"
_INI_
        copyDefaultConfig "${config}" "${md_conf_root}/${md_id}/settings.ini"
        rm "${config}"
    fi

    local config_dir="TFE_DATA_HOME=${md_conf_root}/${md_id}"
    _add_games_forceengine "${config_dir} ${md_inst}/bin/theforceengine"
}
