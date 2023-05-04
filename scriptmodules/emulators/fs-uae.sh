#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="fs-uae"
rp_module_desc="FS-UAE: Commodore Amiga 500, 500+, 600, 1200, CDTV & CD32 Emulator"
rp_module_help="ROM Extension: .adf .adz .bin .cue .dms .ipf .iso .lha .m3u .sh .uae .zip\n\nCopy Amiga Games To: ${romdir}/amiga\nCopy CD32 Games To: ${romdir}/amigacd32\nCopy CDTV Games To: ${romdir}/amigacdtv\n\nCopy BIOS Files:\n\nkick34005.A500\nkick40063.A600\nkick40068.A1200\nkick40060.CD32\nkick34005.CDTV\n\nTo: ${biosdir}/amiga"
rp_module_licence="GPL2 https://raw.githubusercontent.com/FrodeSolheim/fs-uae/master/COPYING"
rp_module_repo="file https://fs-uae.net/files/FS-UAE/Stable/3.1.66/fs-uae-3.1.66.tar.xz"
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
        'python-pillow'
        'python-pyqt5'
        'python-requests'
        'python-rx'
        'python-typing_extensions'
        'python'
        'sdl2'
        'shared-mime-info'
        'zip'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_fs-uae() {
    downloadAndExtract "${md_repo_url}" "${md_build}" --strip-components 1

    _sources_capsimg
    _sources_fs-uae-launcher
}

function _sources_fs-uae-launcher() {
    local url
    url="https://fs-uae.net/files/FS-UAE-Launcher/Stable/3.1.68/fs-uae-launcher-3.1.68.tar.xz"

    downloadAndExtract "${url}" "${md_build}/launcher" --strip-components 1
}

function _sources_capsimg() {
    local url
    url="https://fs-uae.net/files/CAPSImg/Stable/5.1.3/CAPSImg_5.1.3_Linux_x86-64.tar.xz"

    downloadAndExtract "${url}" "${md_build}/capsimg" --strip-components 1
}

function build_fs-uae() {
    ./bootstrap
    ./configure --prefix="${md_inst}"
    make clean
    make
    md_ret_require="${md_build}/${md_id}"
}

function _install_capsimg() {
    install -Dm644 "${md_build}/capsimg/Linux/x86-64/capsimg.so" "${md_inst}/bin/"

    md_ret_require="${md_inst}/bin/capsimg.so"
}

function _install_fs-uae-launcher() {
    make -C "${md_build}/launcher" prefix="${md_inst}" install

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
        mkRomDir "amigacd32"
        mkRomDir "amigacdtv"

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
    addEmulator 1 "${md_id}-cd32" "amigacd32" "${md_inst}/bin/${md_id}.sh %ROM% CD32"
    addEmulator 1 "${md_id}-cdtv" "amigacdtv" "${md_inst}/bin/${md_id}.sh %ROM% CDTV"

    addSystem "amiga"
    addSystem "amigacd32"
    addSystem "amigacdtv"
}
