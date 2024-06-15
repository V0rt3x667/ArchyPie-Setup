#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dxx-rebirth"
rp_module_desc="DXX-Rebirth: Descent & Descent 2 Source Port"
rp_module_licence="NONCOM https://raw.githubusercontent.com/dxx-rebirth/dxx-rebirth/master/COPYING.txt"
rp_module_repo="git https://github.com/dxx-rebirth/dxx-rebirth master"
rp_module_section="opt"
rp_module_flags=""

function depends_dxx-rebirth() {
    local depends=(
        'glu'
        'libpng'
        'mesa'
        'physfs'
        'python'
        'scons'
        'sdl2_image'
        'sdl2_mixer'
        'sdl2'
        'unzip'
    )
    getDepends "${depends[@]}"
}

function sources_dxx-rebirth() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|\"\t${HOME}/.d\" DXX_NAME_NUMBER \"x-rebirth\n\"|\"\t${HOME}/ArchyPie/configs/dxx\" DXX_NAME_NUMBER \"-rebirth\n\"|g" -i "${md_build}/similar/main/inferno.cpp"
    sed -e "s|\"~/.d\" DESCENT_PATH_NUMBER \"x-rebirth/\"|\"~/ArchyPie/configs/dxx\" DESCENT_PATH_NUMBER \"-rebirth/\"|g" -i "${md_build}/similar/misc/physfsx.cpp"
}

function build_dxx-rebirth() {
    local params=()
    isPlatform "arm" && params+=('words_need_alignment=1')
    if isPlatform "rpi"; then
        params+=(
            'opengl=1'
            'opengles=no'
            'raspberrypi=mesa'
            'sdl2=1'
        )
    else
        params+=(
            'opengl=1'
            'opengles=0'
            'sdl2=1'
        )
    fi

    scons -c
    scons "${params[@]}" prefix="${md_inst}" -j"${__jobs}"

    md_ret_require=(
        "${md_build}/build/d1x-rebirth/d1x-rebirth"
        "${md_build}/build/d2x-rebirth/d2x-rebirth"
    )
}

function install_dxx-rebirth() {
    mv -f "${md_build}/d1x-rebirth/INSTALL.txt"       "${md_build}/d1x-rebirth/D1X-INSTALL.txt"
    mv -f "${md_build}/d1x-rebirth/RELEASE-NOTES.txt" "${md_build}/d1x-rebirth/D1X-RELEASE-NOTES.txt"
    mv -f "${md_build}/d2x-rebirth/INSTALL.txt"       "${md_build}/d2x-rebirth/D2X-INSTALL.txt"
    mv -f "${md_build}/d2x-rebirth/RELEASE-NOTES.txt" "${md_build}/d2x-rebirth/D2X-RELEASE-NOTES.txt"

    md_ret_files=(
        'build/d1x-rebirth/d1x-rebirth'
        'build/d2x-rebirth/d2x-rebirth'
        'COPYING.txt'
        'd1x-rebirth/D1X-INSTALL.txt'
        'd1x-rebirth/D1X-RELEASE-NOTES.txt'
        'd1x-rebirth/d1x.ini'
        'd1x-rebirth/README.RPi'
        'd2x-rebirth/D2X-INSTALL.txt'
        'd2x-rebirth/D2X-RELEASE-NOTES.txt'
        'd2x-rebirth/d2x.ini'
        'GPL-3.txt'
    )
}

function _game_data_dxx-rebirth() {
    local base_url="${__archive_url}/descent"
    local D1X_SHARE_URL="${base_url}/descent-pc-shareware.zip"
    local D2X_SHARE_URL="${base_url}/descent2-pc-demo.zip"
    local D1X_HIGH_TEXTURE_URL="${base_url}/d1xr-hires.dxa"
    local D1X_OGG_URL="${base_url}/d1xr-sc55-music.dxa"
    local D2X_OGG_URL="${base_url}/d2xr-sc55-music.dxa"

    local dest_d1="${romdir}/ports/descent1"
    local dest_d2="${romdir}/ports/descent2"

    # Download, Unpack & Install Descent Shareware Files
    if [[ -z "$(find "${dest_d1}" -maxdepth 1 -iname descent.hog)" ]]; then
        downloadAndExtract "${D1X_SHARE_URL}" "${dest_d1}"
    fi

    # High Res Texture Pack
    if [[ ! -f "${dest_d1}/d1xr-hires.dxa" ]]; then
        download "${D1X_HIGH_TEXTURE_URL}" "${dest_d1}"
    fi

    # Ogg Sound Replacement (Roland Sound Canvas SC-55 MIDI)
    if [[ ! -f "${dest_d1}/d1xr-sc55-music.dxa" ]]; then
        download "${D1X_OGG_URL}" "${dest_d1}"
    fi

    # Download, Unpack & Install Descent 2 Shareware Files
    if [[ -z "$(find "${dest_d2}" -maxdepth 1 \( -iname D2DEMO.HOG -o -iname DESCENT2.HOG \))" ]]; then
        downloadAndExtract "${D2X_SHARE_URL}" "${dest_d2}"
    fi

    # Ogg Sound Replacement (Roland Sound Canvas SC-55 MIDI)
    if [[ ! -f "${dest_d2}/d2xr-sc55-music.dxa" ]]; then
        download "${D2X_OGG_URL}" "${dest_d2}"
    fi

    chown -R "${user}:${user}" "${dest_d1}" "${dest_d2}"
}

function configure_dxx-rebirth() {
    local config
	local ver
	local portname="Descent Rebirth"
	
	for ver in 1 2; do
	    [[ "${ver}" -eq 2 ]] && portname="Descent 2 Rebirth"

        moveConfigDir "${arpdir}/dxx${ver}-rebirth" "${md_conf_root}/descent${ver}/"

        if [[ "${md_mode}" == "install" ]]; then
            mkRomDir "ports/descent${ver}"
            
            # Set VSync For 'kms' Platform
            if isPlatform "kms"; then
                config="$(mktemp)"
                iniConfig "=" '' "${config}"
                iniSet "VSync" "1"
                copyDefaultConfig "${config}" "${md_conf_root}/descent${ver}/descent.cfg"
                rm "${config}"
            fi

            # Install Shareware & Data Files
            _game_data_dxx-rebirth
        fi

        addPort "${md_id}" "descent${ver}" "${portname}" "${md_inst}/d${ver}x-rebirth -hogdir ${romdir}/ports/descent${ver}"
    done
}
