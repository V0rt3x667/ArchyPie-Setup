#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dosbox-x"
rp_module_desc="DOSBox-X: MS-DOS Emulator Includes Additional Patches & Features"
rp_module_help="ROM Extensions: .bat .com .conf .exe .sh\n\nCopy DOS Games To: ${romdir}/pc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/joncampbell123/dosbox-x/master/COPYING"
rp_module_repo="git https://github.com/joncampbell123/dosbox-x :_get_branch_dosbox-x"
rp_module_section="opt"
rp_module_flags="!all x86 rpi3 rpi4"

function _get_branch_dosbox-x() {
    download "https://api.github.com/repos/joncampbell123/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_dosbox-x() {
    local depends=(
        'alsa-lib'
        'alsa-utils'
        'ffmpeg'
        'fluidsynth'
        'glu'
        'gzip'
        'libpcap'
        'libpng'
        'libslirp'
        'libxkbfile'
        'libxrandr'
        'ncurses'
        'opusfile'
        'sdl2_image'
        'sdl2_net'
        'sdl2'
        'speexdsp'
    )
    getDepends "${depends[@]}"
}

function sources_dosbox-x() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|\"%s/.config\",|\"%s/ArchyPie/configs\",|g" -i "${md_build}/vs/sdl2/src/core/linux/SDL_ibus.c"
}

function build_dosbox-x() {
    local params=(
        '--disable-debug'
        '--enable-avcodec'
        '--enable-core-inline'
        '--enable-sdl2'
    )
    ! isPlatform "x11" && params+=('--disable-x11')

    ./autogen.sh
    ./configure --prefix="${md_inst}" "${params[@]}"
    make clean
    make
    md_ret_require=("${md_build}/src/dosbox-x")
}

function install_dosbox-x() {
    make install
    md_ret_require=("${md_inst}/bin/dosbox-x")
}

function configure_dosbox-x() {
    configure_dosbox

    if [[ "${md_id}" == "install" ]]; then
        local config_dir="${md_conf_root}/pc"
        chown -R "${user}": "${config_dir}"

        local staging_output="texturenb"
        if isPlatform "kms"; then
            staging_output="openglnb"
        fi

        local config_path
        config_path=$(su "${user}" -c "\"${md_inst}/bin/dosbox-x\" -printconf")
        if [[ -f "${config_path}" ]]; then
            iniConfig " = " "" "${config_path}"
            if isPlatform "rpi"; then
                iniSet "fullscreen" "true"
                iniSet "fullresolution" "original"
                iniSet "vsync" "true"
                iniSet "output" "${staging_output}"
                iniSet "core" "dynamic"
                iniSet "blocksize" "2048"
                iniSet "prebuffer" "50"
            fi
        fi
    fi
}
