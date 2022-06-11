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
    local depends=(libpng physfs scons)
    if isPlatform "videocore"; then
        depends+=(raspberrypi-firmware sdl sdl_mixer sdl_image)
    else
        depends+=(mesa glu sdl2 sdl2_mixer sdl2_image unzip)
    fi

    getDepends "${depends[@]}"
}

function sources_dxx-rebirth() {
    gitPullOrClone
    sed -ie "/^PREFIX =/s|$md_inst|/usr/|" "$md_build/SConstruct"
}

function build_dxx-rebirth() {
    local params=()
    isPlatform "arm" && params+=("words_need_alignment=1")
    if isPlatform "videocore"; then
        params+=("raspberrypi=1")
    elif isPlatform "mesa"; then
        # GLES is limited to ES 1 and blocks SDL2; GL works at fullspeed on Pi 3.
        params+=("raspberrypi=mesa" "opengl=1" "opengles=0" "sdl2=1")
    else
        params+=("opengl=1" "opengles=0" "sdl2=1")
    fi

    scons -c
    scons "${params[@]}" -j$__jobs
    md_ret_require=(
        "$md_build/build/d1x-rebirth/d1x-rebirth"
        "$md_build/build/d2x-rebirth/d2x-rebirth"
    )
}

function install_dxx-rebirth() {
    # Rename generic files
    mv -f "$md_build/d1x-rebirth/INSTALL.txt" "$md_build/d1x-rebirth/D1X-INSTALL.txt"
    mv -f "$md_build/d1x-rebirth/RELEASE-NOTES.txt" "$md_build/d1x-rebirth/D1X-RELEASE-NOTES.txt"
    mv -f "$md_build/d2x-rebirth/INSTALL.txt" "$md_build/d2x-rebirth/D2X-INSTALL.txt"
    mv -f "$md_build/d2x-rebirth/RELEASE-NOTES.txt" "$md_build/d2x-rebirth/D2X-RELEASE-NOTES.txt"

    md_ret_files=(
        'COPYING.txt'
        'GPL-3.txt'
        'd1x-rebirth/README.RPi'
        'build/d1x-rebirth/d1x-rebirth'
        'd1x-rebirth/d1x.ini'
        'd1x-rebirth/D1X-INSTALL.txt'
        'd1x-rebirth/D1X-RELEASE-NOTES.txt'
        'build/d2x-rebirth/d2x-rebirth'
        'd2x-rebirth/d2x.ini'
        'd2x-rebirth/D2X-INSTALL.txt'
        'd2x-rebirth/D2X-RELEASE-NOTES.txt'
    )
}

function _game_data_dxx-rebirth() {
    local D1X_SHARE_URL='https://www.dxx-rebirth.com/download/dxx/content/descent-pc-shareware.zip'
    local D2X_SHARE_URL='https://www.dxx-rebirth.com/download/dxx/content/descent2-pc-demo.zip'
    local D1X_HIGH_TEXTURE_URL='https://www.dxx-rebirth.com/download/dxx/res/d1xr-hires.dxa'
    local D1X_OGG_URL='https://www.dxx-rebirth.com/download/dxx/res/d1xr-sc55-music.dxa'
    local D2X_OGG_URL='https://www.dxx-rebirth.com/download/dxx/res/d2xr-sc55-music.dxa'

    local dest_d1="$romdir/ports/descent1"
    local dest_d2="$romdir/ports/descent2"

    mkUserDir "$dest_d1"
    mkUserDir "$dest_d2"

    # Download / unpack / install Descent shareware files
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

    # Download / unpack / install Descent 2 shareware files
    if [[ ! -f "$dest_d2/D2DEMO.HOG" ]]; then
        downloadAndExtract "$D2X_SHARE_URL" "$dest_d2"
    fi

    # Ogg Sound Replacement (Roland Sound Canvas SC-55 MIDI)
    if [[ ! -f "$dest_d2/d2xr-sc55-music.dxa" ]]; then
        download "$D2X_OGG_URL" "$dest_d2"
    fi

    chown -R $user:$user "$dest_d1" "$dest_d2"
}

function configure_dxx-rebirth() {
    local config
    local ver
    local name="Descent Rebirth"
    for ver in 1 2; do
        [[ "$ver" -eq 2 ]] && name="Descent II Rebirth"
        addPort "$md_id" "descent${ver}" "$name" "$md_inst/d${ver}x-rebirth -hogdir $romdir/ports/descent${ver}"

        # skip folder / config work on removal
        [[ "$md_mode" == "remove" ]] && continue

        mkRomDir "ports/descent${ver}"
        # copy any existing configs from ~/.d1x-rebirth and symlink the config folder to $md_conf_root/descent1/
        moveConfigDir "$home/.d${ver}x-rebirth" "$md_conf_root/descent${ver}/"
        if isPlatform "kms"; then
            config="$md_conf_root/descent${ver}/descent.cfg"
            iniConfig "=" '' "$config"
            iniSet "VSync" "1"
            chown "$user:$user" "$config"
        fi
    done

    [[ "$md_mode" == "install" ]] && _game_data_dxx-rebirth
}
