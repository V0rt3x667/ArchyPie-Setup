#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="wolf4sdl"
rp_module_desc="Wolf4SDL: Port of Wolfenstein 3D & Spear of Destiny"
rp_module_licence="GPL2 https://raw.githubusercontent.com/fabiangreffrath/wolf4sdl/master/license-gpl.txt"
rp_module_repo="git https://github.com/fabiangreffrath/wolf4sdl master"
rp_module_section="opt"
rp_module_flags=""

function depends_wolf4sdl() {
     local depends=(
        'perl-rename'
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_wolf4sdl() {
    gitPullOrClone
}

function _get_opts_wolf4sdl() {
    echo 'wolf4sdl-sw-v14 -DCARMACIZED -DUPLOAD' # Shareware v1.4
    echo 'wolf4sdl-3dr-v14 -DCARMACIZED' # 3D Realms/Apogee v1.4 Full
    echo 'wolf4sdl-gt-v14 -DCARMACIZED -DGOODTIMES' # GT/id/Activision v1.4 Full
    echo 'wolf4sdl-spear -DCARMACIZED -DGOODTIMES -DSPEAR' # Spear of Destiny
    echo 'wolf4sdl-spear-sw -DCARMACIZED -DSPEARDEMO -DSPEAR' # Spear of Destiny Demo
}

function build_wolf4sdl() {
    mkdir -p "bin"
    local opt
    while read -r opt; do
        local bin="${opt%% *}"
        local defs="${opt#* }"
        make clean
        CFLAGS+=" -DVERSIONALREADYCHOSEN -DGPL ${defs}" make
        mv wolf3d "bin/${bin}"
        md_ret_require+=("bin/${bin}")
    done < <(_get_opts_wolf4sdl)
}

function install_wolf4sdl() {
    md_ret_files=('bin/')
}

function _game_data_wolf4sdl() {
    local portname
    portname="wolf3d"

    # Get Wolfenstein 3D Shareware Game Data
    if [[ ! -f "${romdir}/ports/${portname}/vswap.wl6" ]] && [[ ! -f "${romdir}/ports/${portname}/vswap.wl1" ]]; then
        cd "${__tmpdir}" || exit
        downloadAndExtract "http://maniacsvault.net/ecwolf/files/shareware/wolf3d14.zip" "${romdir}/ports/${portname}" -j -LL
    fi

    # Get Spear of Destiny Shareware Game Data
    if [[ ! -f "${romdir}/ports/${portname}/vswap.sdm" ]] && [[ ! -f "${romdir}/ports/${portname}/vswap.sod" ]]; then
        cd "${__tmpdir}" || exit
        downloadAndExtract "http://maniacsvault.net/ecwolf/files/shareware/soddemo.zip" "${romdir}/ports/${portname}" -j -LL
    fi

    chown -R "${user}:${user}" "${romdir}/ports/${portname}"
}

function _add_games_wolf4sdl() {
    local cmd="$1"
    local dir
    local game
    local portname
    declare -A games=(
        ['vswap.sd1']="Wolfenstein 3D: Spear of Destiny"
        ['vswap.sd2']="Wolfenstein 3D: Spear of Destiny: Mission Pack 2: Return to Danger"
        ['vswap.sd3']="Wolfenstein 3D: Spear of Destiny: Mission Pack 3: Ultimate Challenge"
        ['vswap.sdm']="Wolfenstein 3D: Spear of Destiny (Shareware)"
        ['vswap.sod']="Wolfenstein 3D: Spear of Destiny"
        ['vswap.wl1']="Wolfenstein 3D: Wolfenstein 3D (Shareware)"
        ['vswap.wl6']="Wolfenstein 3D: Wolfenstein 3D"
    )
    if [[ "${md_id}" == "ecwolf" ]]; then
        games+=(['vswap.n3d']="Super Noah's Ark 3D")
    fi

    # Create .sh Files For Each Game Found. Uppercase Filenames Will Be Converted to Lowercase.
    for game in "${!games[@]}"; do
        portname="wolf3d"
        dir="${romdir}/ports/${portname}/"
        if [[ "${md_mode}" == "install" ]]; then
            pushd "${dir}" || return
            perl-rename 'y/A-Z/a-z/' [^.-]{*,*/*}
            popd || return
        fi
        if [[ -f "${dir}/${game}" ]]; then
            if [[ "${md_id}" == "ecwolf" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "$cmd" "${game##*.}"
            elif [[ "${md_id}" == "splitwolf" ]]; then
                addPort "${md_id}" "splitwolf" "SplitWolf: ${games[$game]/Wolfenstein 3D:/}" "${cmd}" "${game}"
            else
                addPort "$md_id" "${portname}" "${games[$game]}" "${cmd}" "${game}"
            fi
        fi
    done
}

function configure_wolf4sdl() {
    local portname
    portname="wolf3d"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ports/${portname}"
        _game_data_wolf4sdl

        cat > "${md_inst}/bin/${md_id}.sh" << _EOF_
#!/bin/bash

function get_md5sum() {
    local file="\$1"

    [[ -n "\${file}" ]] && md5sum "\${file}" 2>/dev/null | cut -d" " -f1
}

function launch_wolf4sdl() {
    local wad_file="\$1"
    declare -A game_checksums=(
        ['6efa079414b817c97db779cecfb081c9']="wolf4sdl-sw-v14"
        ['a6d901dfb455dfac96db5e4705837cdb']="wolf4sdl-3dr-v14"
        ['b8ff4997461bafa5ef2a94c11f9de001']="wolf4sdl-gt-v14"
        ['b1dac0a8786c7cdbb09331a4eba00652']="wolf4sdl-spear --mission 1"
        ['25d92ac0ba012a1e9335c747eb4ab177']="wolf4sdl-spear --mission 2"
        ['94aeef7980ef640c448087f92be16d83']="wolf4sdl-spear --mission 3"
        ['e3e87518f51414872c454b7d72a45af6']="wolf4sdl-spear --mission 3"
        ['35afda760bea840b547d686a930322dc']="wolf4sdl-spear-sw"
    )
    if [[ "\${game_checksums[\$(get_md5sum \${wad_file})]}" ]] 2>/dev/null; then
        pushd "${romdir}/ports/${portname}"
        ${md_inst}/bin/\${game_checksums[\$(get_md5sum \${wad_file})]} --configdir "${arpdir}/${md_id}" --fullscreen
        popd
    else
        echo "Error: \${wad_file} (md5: \$(get_md5sum \${wad_file})) is not a supported version!"
    fi
}

launch_wolf4sdl "\$1"
_EOF_
        chmod +x "${md_inst}/bin/${md_id}.sh"
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"

    _add_games_wolf4sdl "${md_inst}/bin/${md_id}.sh ${romdir}/ports/${portname}/%ROM%"
}
