#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="citra"
rp_module_desc="Citra: Nintendo 3DS Emulator"
rp_module_help="ROM Extensions: .3ds .3dsx .app .axf .cci .cia .cxi .elf\n\nCopy Nintendo 3DS ROMs To: ${romdir}/3ds\n\nNote: .cia ROMs Will Only Work If A 'aes_keys.txt' File Exists In The 'sysdata' Folder"
rp_module_licence="GPL2 https://raw.githubusercontent.com/citra-emu/citra/master/license.txt"
rp_module_repo="git https://github.com/citra-emu/citra master"
rp_module_section="main"
rp_module_flags="!all 64bit"

function depends_citra() {
    local depends=(
        'boost'
        'cmake'
        'doxygen'
        'ffmpeg'
        'fmt'
        'libfdk-aac'
        'ninja'
        'qt5-base'
        'qt5-multimedia'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_citra() {
    gitPullOrClone

    # Set Default Config Path(s)
    #applyPatch "${md_data}/01_set_default_config_path.patch"

}

function build_citra() {
    # "ninja -C build clean" Removes An Object From The Build Dir Resulting In A Compliation Failure:
    # "fatal error: shaders/depth_to_color.frag: No such file or directory"
    if [[ -d "${md_build}/build" ]]; then
        rm -rf "${md_build}/build"
    fi

    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DENABLE_FFMPEG_AUDIO_DECODER="ON" \
        -DENABLE_WEB_SERVICE="OFF" \
        -DUSE_SYSTEM_BOOST="ON" \
        -DUSE_SYSTEM_SDL2="ON" \
        -Wno-dev
    ninja -C build
    md_ret_require="${md_build}/build/bin/Release/${md_id}"
}

function install_citra() {
    ninja -C build install/strip
}

function configure_citra() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "3ds"
    fi

    #moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/3ds/${md_id}"

    addEmulator 1 "${md_id}" "3ds" "${md_inst}/bin/${md_id} -f %ROM%"
    addEmulator 0 "${md_id}-gui" "3ds" "${md_inst}/bin/${md_id}-qt -f %ROM%"

    addSystem "3ds"
}
