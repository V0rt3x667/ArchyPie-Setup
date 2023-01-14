#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dosbox-staging"
rp_module_desc="DOSBox-Staging: MS-DOS x86 Emulator"
rp_module_help="ROM Extensions: .bat .com .conf .exe .sh\n\nCopy DOS Games To: ${romdir}/pc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/dosbox-staging/dosbox-staging/master/COPYING"
rp_module_repo="git https://github.com/dosbox-staging/dosbox-staging :_get_branch_dosbox-staging"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_dosbox-staging() {
    download "https://api.github.com/repos/${md_id}/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_dosbox-staging() {
    local depends=(
        'alsa-lib'
        'alsa-utils'
        'cmake'
        'fluidsynth'
        'gzip'
        'libpng'
        'libslirp'
        'meson'
        'ncurses'
        'ninja'
        'opusfile'
        'sdl2_image'
        'sdl2_net'
        'sdl2'
        'speexdsp'
    )
    getDepends "${depends[@]}"
}

function sources_dosbox-staging() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|: \"~/.config\";|: \"ArchyPie/configs\";|g" -i "${md_build}/src/misc/cross.cpp"
}

function build_dosbox-staging() {
    local params=(
        -Dbuildtype="release"
        -Ddatadir="resources"
        -Dtry_static_libs="mt32emu"
    )

    meson setup -Dprefix="${md_inst}" "${params[@]}" build
    meson compile -j"${__jobs}" -C build

    md_ret_require=("${md_build}/build/dosbox")
}

function install_dosbox-staging() {
    ninja -C build install
    md_ret_require=("${md_inst}/bin/dosbox")
}

function configure_dosbox-staging() {
    configure_dosbox

    if [[ "${md_id}" == "install" ]]; then
        local config_dir="${md_conf_root}/pc"
        chown -R "${user}": "${config_dir}"

        local staging_output="texturenb"
        if isPlatform "kms"; then
            staging_output="openglnb"
        fi

        local config_path
        config_path=$(su "${user}" -c "\"${md_inst}/bin/dosbox\" -printconf")
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
