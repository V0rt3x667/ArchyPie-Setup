#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="fs-uae"
rp_module_desc="FS-UAE: Commodore Amiga 500, 500+, 600, 1200, CDTV & CD32 Emulator"
rp_module_help="ROM Extension: .adf .adz .bin .chd .cue .dms .ipf .iso .lha .m3u .sh .uae .zip\n\nCopy Amiga Games To: ${romdir}/amiga\n\nCopy CD32 Games To: ${romdir}/cd32\n\nCopy CDTV Games To: ${romdir}/cdtv\n\nCopy BIOS Files:\n\nkick13.rom\nkick20.rom\nkick31.rom\n\nTo: ${biosdir}/amiga"
rp_module_licence="GPL2 https://raw.githubusercontent.com/FrodeSolheim/fs-uae/master/COPYING"
rp_module_repo="git https://github.com/FrodeSolheim/fs-uae :_get_branch_fs-uae"
rp_module_section="main"
rp_module_flags="!all x86_64"

function depends_fs-uae() {
    local depends=(
        'desktop-file-utils'
        'freetype2'
        'gettext'
        'glib2'
        'hicolor-icon-theme'
        'libmpeg2'
        'libpng' 
        'libx11'
        'libxi'
        'mesa'
        'openal'
        'python-lhafile'
        'python-pyqt5'
        'python-rx'
        'python'
        'sdl2'
        'shared-mime-info'
        'zip'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function _get_branch_fs-uae() {
    download "https://api.github.com/repos/FrodeSolheim/fs-uae/releases" - | grep -m 1 tag_name | cut -d\" -f4
}

function _get_branch_fs-uae-launcher() {
    download "https://api.github.com/repos/FrodeSolheim/fs-uae-launcher/releases" - | grep -m 1 tag_name | cut -d\" -f4
}

function _get_branch_capsimg() {
    download "https://api.github.com/repos/FrodeSolheim/capsimg/releases" - | grep -m 1 tag_name | cut -d\" -f4
}

function sources_fs-uae() {
    gitPullOrClone

    _sources_capsimg
    _sources_fs-uae-launcher
}

function _sources_fs-uae-launcher() {
    local tag
    tag="$(_get_branch_fs-uae-launcher)"

    gitPullOrClone "${md_build}/launcher" "https://github.com/FrodeSolheim/fs-uae-launcher" "${tag}"

    # Set Installation Prefix
    sed -e "s|/usr/local|${md_inst}|g" -i "${md_build}/launcher/bootstrap"
}

function _sources_capsimg() {
    local tag
    tag="$(_get_branch_capsimg)"

    gitPullOrClone "${md_build}/capsimg" "https://github.com/FrodeSolheim/capsimg" "${tag}"
}

function _build_capsimg() {
    cd "${md_build}/capsimg/CAPSImg" || exit
    chmod a+x ./bootstrap.sh
    ./bootstrap.sh
    ./configure
    make clean
    make
    mv libcapsimage.so.5.1 capsimg.so
    md_ret_require="${md_build}/capsimg/CAPSImg/capsimg.so"
}

function _build_fs-uae-launcher() {
    cd "${md_build}/launcher" || exit
    ./bootstrap
    ./update-version
    make clean
    make
    md_ret_require="${md_build}/launcher/${md_id}-launcher"
}

function build_fs-uae() {
    _build_capsimg
    _build_fs-uae-launcher

    cd "${md_build}" || exit
    ./bootstrap
    ./configure --prefix="${md_inst}"
    make clean
    make
    md_ret_require="${md_build}/${md_id}"
}

function _install_capsimg() {
    install -Dm644 "${md_build}/capsimg/CAPSImg/capsimg.so" "${md_inst}/bin/"
    md_ret_require="${md_inst}/bin/capsimg.so"
}

function _install_fs-uae-launcher() {
    make -C "${md_build}/launcher" install
    md_ret_require="${md_inst}/bin/${md_id}-launcher"
}

function install_fs-uae() {
    make install
    _install_capsimg
    _install_fs-uae-launcher
    md_ret_require="${md_inst}/bin/${md_id}"
}

function configure_fs-uae() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/amiga/${md_id}"

    # Required For 'fs-uae-launcher'
    moveConfigDir "${md_conf_root}/amiga/${md_id}/Kickstarts" "${biosdir}/amiga/"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "amiga"
        mkRomDir "cd32"
        mkRomDir "cdtv"

        mkUserDir "${biosdir}/amiga"
        mkUserDir "${biosdir}/amiga/workbench"

        # Copy Launcher Script
        install -Dm755 "${md_data}/${md_id}.sh" "${md_inst}/bin"

        # Set Default Config File
        local config
        config="$(mktemp)"
        iniConfig " = " "" "${config}"

        iniSet "base_dir" "${arpdir}/${md_id}"
        iniSet "logs_dir" "${arpdir}/${md_id}"
        iniSet "cache_dir" "${arpdir}/${md_id}"
        iniSet "kickstarts_dir" "${biosdir}/amiga"
        iniSet "fullscreen" "1"
        iniSet "keep_aspect" "1"
        iniSet "video_sync" "Auto"
        iniSet "zoom" "full"
        iniSet "fsaa" "0"
        iniSet "scanlines" "0"
        iniSet "floppy_drive_speed" "100"

        copyDefaultConfig "${config}" "${arpdir}/${md_id}/Config.fs-uae"
        rm "${config}"

        # Copy 'fs-uae-launcher' Script
        local script="+Start FS-UAE.sh"
        cat > "${romdir}/amiga/${script}" << _EOF_
#!/bin/bash
FS_UAE_BASE_DIR="${arpdir}/${md_id}" "${md_inst}/bin/${md_id}-launcher"
_EOF_
        chmod a+x "${romdir}/amiga/${script}"
        chown "${user}:${user}" "${romdir}/amiga/${script}"
    fi

    addEmulator 0 "${md_id}-a1200" "amiga" "${md_inst}/bin/${md_id}.sh %ROM% A1200"
    addEmulator 0 "${md_id}-a500plus" "amiga" "${md_inst}/bin/${md_id}.sh %ROM% A500+"
    addEmulator 0 "${md_id}-a600" "amiga" "${md_inst}/bin/${md_id}.sh %ROM% A600"
    addEmulator 0 "${md_id}-whdload" "amiga" "${md_inst}/bin/${md_id}.sh %ROM% WHDLOAD"
    addEmulator 1 "${md_id}-a500" "amiga" "${md_inst}/bin/${md_id}.sh %ROM% A500"
    addEmulator 1 "${md_id}-cd32" "cd32" "${md_inst}/bin/${md_id}.sh %ROM% CD32"
    addEmulator 1 "${md_id}-cdtv" "cdtv" "${md_inst}/bin/${md_id}.sh %ROM% CDTV"

    addSystem "amiga"
    addSystem "cd32"
    addSystem "cdtv"
}
