#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dxx-rebirth"
rp_module_desc="DXX-Rebirth - Descent & Descent 2 Source Port"
rp_module_licence="NONCOM https://raw.githubusercontent.com/dxx-rebirth/dxx-rebirth/master/COPYING.txt"
rp_module_repo="git https://github.com/dxx-rebirth/dxx-rebirth.git master"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_dxx-rebirth() {
    local depends=(
        'libpng'
        'physfs'
        'scons'
    )
    if isPlatform "videocore"; then
        depends+=(
            'raspberrypi-firmware'
            'sdl'
            'sdl_image'
            'sdl_mixer'
        )
    else
        depends+=(
            'glu'
            'mesa'
            'sdl2'
            'sdl2_image'
            'sdl2_mixer'
            'unzip'
        )
    fi
    getDepends "${depends[@]}"
}

function sources_dxx-rebirth() {
    gitPullOrClone

    applyPatch "$md_data/01_set_default_config_path.patch"
}

function build_dxx-rebirth() {
    local params=()
    isPlatform "arm" && params+=("words_need_alignment=1")
    if isPlatform "videocore"; then
        params+=("raspberrypi=1")
    elif isPlatform "mesa"; then
        params+=("raspberrypi=mesa" "opengl=1" "opengles=0" "sdl2=1")
    else
        params+=("opengl=1" "opengles=0" "sdl2=1")
    fi

    scons -c
    scons "${params[@]}" prefix="$md_inst" -j$__jobs

    md_ret_require=(
        "$md_build/build/d1x-rebirth/d1x-rebirth"
        "$md_build/build/d2x-rebirth/d2x-rebirth"
    )
}

function install_dxx-rebirth() {
    mv -f "$md_build/d1x-rebirth/INSTALL.txt" "$md_build/d1x-rebirth/D1X-INSTALL.txt"
    mv -f "$md_build/d1x-rebirth/RELEASE-NOTES.txt" "$md_build/d1x-rebirth/D1X-RELEASE-NOTES.txt"
    mv -f "$md_build/d2x-rebirth/INSTALL.txt" "$md_build/d2x-rebirth/D2X-INSTALL.txt"
    mv -f "$md_build/d2x-rebirth/RELEASE-NOTES.txt" "$md_build/d2x-rebirth/D2X-RELEASE-NOTES.txt"

    md_ret_files=(
        'COPYING.txt'
        'GPL-3.txt'
        'build/d1x-rebirth/d1x-rebirth'
        'build/d2x-rebirth/d2x-rebirth'
        'd1x-rebirth/D1X-INSTALL.txt'
        'd1x-rebirth/D1X-RELEASE-NOTES.txt'
        'd1x-rebirth/README.RPi'
        'd1x-rebirth/d1x.ini'
        'd2x-rebirth/D2X-INSTALL.txt'
        'd2x-rebirth/D2X-RELEASE-NOTES.txt'
        'd2x-rebirth/d2x.ini'
    )
}

function _game_data_dxx-rebirth() {
    local D1X_HIGH_TEXTURE_URL='https://www.dxx-rebirth.com/download/dxx/res/d1xr-hires.dxa'
    local D1X_OGG_URL='https://www.dxx-rebirth.com/download/dxx/res/d1xr-sc55-music.dxa'
    local D1X_SHARE_URL='https://www.dxx-rebirth.com/download/dxx/content/descent-pc-shareware.zip'
    local D2X_OGG_URL='https://www.dxx-rebirth.com/download/dxx/res/d2xr-sc55-music.dxa'
    local D2X_SHARE_URL='https://www.dxx-rebirth.com/download/dxx/content/descent2-pc-demo.zip'
    local dest_d1="$romdir/ports/descent1"
    local dest_d2="$romdir/ports/descent2"

    # Download, Unpack & Install Descent Shareware Files
    if [[ ! -f "$dest_d1/descent.hog" ]]; then
        downloadAndExtract "$D1X_SHARE_URL" "$dest_d1"
    fi

    # High Res Texture Pack
    if [[ ! -f "$dest_d1/d1xr-hires.dxa" ]]; then
        download "$D1X_HIGH_TEXTURE_URL" "$dest_d1"
    fi

    # Ogg Sound Replacement (Roland Sound Canvas SC-55 MIDI)
    if [[ ! -f "$dest_d1/d1xr-sc55-music.dxa" ]]; then
        download "$D1X_OGG_URL" "$dest_d1"
    fi

    # Download, Unpack & Install Descent 2 Shareware Files
    if [[ ! -f "$dest_d2/D2DEMO.HOG" ]]; then
        downloadAndExtract "$D2X_SHARE_URL" "$dest_d2"
    fi

    # Ogg Sound Replacement (Roland Sound Canvas SC-55 MIDI)
    if [[ ! -f "$dest_d2/d2xr-sc55-music.dxa" ]]; then
        download "$D2X_OGG_URL" "$dest_d2"
    fi

    chown -R "$user:$user" "$dest_d1" "$dest_d2"
}

function configure_dxx-rebirth() {
    if [[ "$md_mode" == "install" ]]; then
        mkRomDir "ports/descent1"
        mkRomDir "ports/descent2"
    fi

    addPort "$md_id" "descent1" "Descent Rebirth" "$md_inst/d1x-rebirth -hogdir $romdir/ports/descent1"
    addPort "$md_id" "descent2" "Descent II Rebirth" "$md_inst/d2x-rebirth -hogdir $romdir/ports/descent2"

    moveConfigDir "$arpiedir/ports/dxx1-rebirth" "$md_conf_root/descent1/"
    moveConfigDir "$arpiedir/ports/dxx2-rebirth" "$md_conf_root/descent2/"

    if [[ "$md_mode" == "install" ]]; then
        if isPlatform "kms"; then
            for ver in 1 2; do 
                config="$md_conf_root/descent${ver}/descent.cfg"
                iniConfig "=" '' "$config"
                iniSet "VSync" "1"
                chown "$user:$user" "$config"
            done
        fi
        _game_data_dxx-rebirth
    fi
}
