#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="uqm"
rp_module_desc="The Ur-Quan Masters - Star Control 2 Port"
rp_module_licence="GPL2 https://sourceforge.net/p/sc2/uqm/ci/v0.8.0-1/tree/sc2/COPYING"
rp_module_repo="file https://sourceforge.net/projects/sc2/files/UQM/0.8/uqm-0.8.0-src.tgz"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_uqm() {
    local depends=(
        'imagemagick'
        'libglvnd'
        'libmikmod' 
        'libogg'
        'libvorbis' 
        'openal'
        'sdl_image'
    )
    isPlatform "gl" || isPlatform "mesa" && depends+=(mesa)
    isPlatform "kms" && depends+=(xorg-server)
    getDepends "${depends[@]}"
}

function sources_uqm() {
    downloadAndExtract "$md_repo_url" "$md_build" --strip-components 1
    local ver="0.8.0"
    local url="https://sourceforge.net/projects/sc2/files/UQM/0.8"
    local file=(
        uqm-$ver-content.uqm
        uqm-$ver-voice.uqm
        uqm-$ver-3domusic.uqm
    )
    for f in "${file[@]}"; do
        if [[ $f == uqm-$ver-content.uqm ]]; then
            curl --create-dirs -sSL "$url/$f" --output "$md_build/content/packages/$f"
        else 
            curl --create-dirs -sSL "$url/$f" --output "$md_build/content/addons/$f"
        fi
    done
    chmod -R 755 "$md_build/content"
}

function build_uqm() {
    local file="$md_build/config.state"
    cat >"$file" << _EOF_
CHOICE_debug_VALUE='nodebug'
CHOICE_graphics_VALUE='opengl'
CHOICE_sound_VALUE='mixsdl'
CHOICE_mikmod_VALUE='external'
CHOICE_ovcodec_VALUE='standard'
CHOICE_netplay_VALUE='full'
CHOICE_joystick_VALUE='enabled'
CHOICE_ioformat_VALUE='stdio_zip'
CHOICE_accel_VALUE='asm'
CHOICE_threadlib_VALUE='sdl'
INPUT_install_prefix_VALUE='$md_inst'
INPUT_install_bindir_VALUE='$prefix'
INPUT_install_libdir_VALUE='$prefix'
INPUT_install_sharedir_VALUE='$prefix'
_EOF_

    ./build.sh uqm reprocess_config && ./build.sh uqm
    md_ret_require="$md_build/uqm"
}

function install_uqm() {
    md_ret_files=(
        'uqm'
        'content'
    )
}

function configure_uqm() {
    local binary="$md_inst/uqm"
    local params=("-f" "--contentdir=$md_inst/content" "--addondir=$md_inst/content")
    if isPlatform "kms"; then
        binary="XINIT:$md_inst/$binary"
        # OpenGL mode must be also be enabled for high resolution support
        params+=("-o" "-r %XRES%x%YRES%")
    elif isPlatform "gl"; then
        params+=("-o")
    fi
    moveConfigDir "$home/.uqm" "$md_conf_root/uqm"
    addPort "$md_id" "uqm" "Ur-Quan Masters" "$binary ${params[*]}"
}
