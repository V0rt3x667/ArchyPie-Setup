#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="scummvm"
rp_module_desc="ScummVM: Virtual Machine for Graphical Point-and-Click Adventure Games"
rp_module_help="ROM Extensions: .sh .svm\n\nCopy ScummVM Games To: ${romdir}/scummvm"
rp_module_licence="GPL3 https://raw.githubusercontent.com/scummvm/scummvm/master/COPYING"
rp_module_repo="git https://github.com/scummvm/scummvm :_get_branch_scummvm"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_scummvm() {
    download "https://api.github.com/repos/${md_id}/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_scummvm() {
    local depends=(
        'a52dec'
        'faad2'
        'flac'
        'fluidsynth'
        'freetype2'
        'libjpeg-turbo'
        'libmad'
        'libmpeg2'
        'libpng'
        'libspeechd'
        'libtheora'
        'libvorbis'
        'sdl2_net'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_scummvm() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|savePath = \".local/share/\";|savePath = \"ArchyPie/configs/${md_id}/\";|g" -i "${md_build}/backends/saves/posix/posix-saves.cpp"
    sed -e "s|.config\"|ArchyPie/configs/${md_id}\"|g" -i "${md_build}/backends/platform/sdl/posix/posix.cpp"
}

function build_scummvm() {
    local params=(
        --disable-debug
        --disable-eventrecorder
        --enable-all-engines
        --enable-release
        --enable-vkeybd
        --prefix="${md_inst}"
    )
    isPlatform "rpi" && isPlatform "32bit" && params+=('--host=raspberrypi')
    isPlatform "gles" && params+=('--opengl-mode=gles2')

    ./configure "${params[@]}"
    make clean
    make
    md_ret_require="${md_build}/${md_id}"
}

function install_scummvm() {
    make install
    mkdir -p "${md_inst}/extra"
    cp -v backends/vkeybd/packs/vkeybd_*.zip "${md_inst}/extra"
}

function configure_scummvm() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "${md_id}"

        # Create Launcher Script
        local name="ScummVM"
        cat > "${romdir}/${md_id}/+Start ${name}.sh" << _EOF_
#!/bin/bash
game="\$1"
pushd "${romdir}/${md_id}" >/dev/null
${md_inst}/bin/${md_id} --fullscreen --joystick=0 --extrapath="${md_inst}/extra" "\${game}"
while read id desc; do
    echo "\${desc}" > "${romdir}/${md_id}/\${id}.svm"
done < <(${md_inst}/bin/${md_id} --list-targets | tail -n +3)
popd >/dev/null
_EOF_
        chown "${user}:${user}" "${romdir}/${md_id}/+Start ${name}.sh"
        chmod u+x "${romdir}/${md_id}/+Start ${name}.sh"
    fi

    addEmulator 1 "${md_id}" "${md_id}" "bash ${romdir}/${md_id}/+Start\ ${name}.sh %BASENAME%"

    addSystem "${md_id}"
}
