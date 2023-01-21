#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="pcsx-rearmed"
rp_module_desc="PCSX ARM Optimised: Sony Playstation Emulator"
rp_module_help="ROM Extensions: .bin .cue .cbn .img .iso .m3u .mdf .pbp .toc .z .znx\n\nCopy PSX ROMs To: ${romdir}/psx\n\nCopy BIOS File SCPH1001.BIN to ${biosdir}/"
rp_module_licence="GPL2 https://raw.githubusercontent.com/notaz/pcsx_rearmed/master/COPYING"
rp_module_repo="git https://github.com/notaz/pcsx_rearmed master"
rp_module_section="opt"
rp_module_flags="!all rpi"

function depends_pcsx-rearmed() {
    local depends=(
        'ffmpeg'
        'libpng'
        'libx11'
        'sdl12-compat'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_pcsx-rearmed() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|/.pcsx/|/ArchyPie/configs/${md_id}/|g" -i "${md_build}/frontend/main.h"
    sed -e "s|/.pcsx/|/ArchyPie/configs/${md_id}/|g" -i "${md_build}/frontend/main.c"
}

function build_pcsx-rearmed() {
    if isPlatform "neon"; then
        ./configure --sound-drivers=alsa --enable-neon
    else
        ./configure --sound-drivers=alsa --disable-neon
    fi
    make clean
    make
    md_ret_require="${md_build}/${md_id}"
}

function install_pcsx-rearmed() {
    md_ret_files=(
        'AUTHORS'
        'ChangeLog.df'
        'ChangeLog'
        'COPYING'
        'NEWS'
        'pcsx'
        'README.md'
        'readme.txt'
    )

    mkdir "${md_inst}/plugins"
    cp "${md_build}/plugins/spunull/spunull.so" "${md_inst}/plugins/spunull.so"
    cp "${md_build}/plugins/gpu_unai/gpu_unai.so" "${md_inst}/plugins/gpu_unai.so"
    cp "${md_build}/plugins/gpu-gles/gpu_gles.so" "${md_inst}/plugins/gpu_gles.so"
    cp "${md_build}/plugins/dfxvideo/gpu_peops.so" "${md_inst}/plugins/gpu_peops.so"
}

function configure_pcsx-rearmed() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/psx/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "psx"
        mkUserDir "${biosdir}/psx"

        # Create & Symlink BIOS Directory
        mkdir -p "${md_inst}/bios"
        ln -sf "${biosdir}/psx" "${md_inst}/bios"
    fi

    addEmulator 0 "${md_id}" "psx" "pushd ${md_inst}; ${md_inst}/pcsx -cdfile %ROM%; popd"

    addSystem "psx"
}
