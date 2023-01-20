#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="openmsx"
rp_module_desc="OpenMSX: Microsoft MSX, MSX2, MSX2+ & TurboR Emulator"
rp_module_help="ROM Extensions: .cas .col .dsk .mx1 .mx2 .rom .zip\n\nCopy MSX/MSX2 Games To: ${romdir}/msx\nCopy BIOS Files To: ${biosdir}/msx"
rp_module_licence="GPL2 https://raw.githubusercontent.com/openMSX/openMSX/master/doc/GPL.txt"
rp_module_repo="git https://github.com/openMSX/openMSX :_get_branch_openmsx"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_openmsx() {
    download "https://api.github.com/repos/openMSX/openMSX/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_openmsx() {
    local depends=(
        'alsa-lib'
        'libogg'
        'libpng'
        'libtheora'
        'libvorbis'
        'python'
        'sdl2_ttf'
        'sdl2'
        'tcl'
        'zlib'
    )
    isPlatform "x11" && depends+=('glew')

    getDepends "${depends[@]}"
}

function sources_openmsx() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|(\"~/.openMSX\");|(\"~/ArchyPie/configs/${md_id}\");|g" -i "${md_build}/src/file/FileOperations.cc"
    sed -e "s|-types {hidden d} \".openMSX\"|-types \"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/share/scripts/_osd_menu.tcl"

    # Set Installation Prefix
    sed -e "s|INSTALL_BASE:=/opt/openMSX|INSTALL_BASE:=${md_inst}|g" -i "${md_build}/build/custom.mk"

    # Do Not Symlink Binary
    sed -e "s|SYMLINK_FOR_BINARY:=true|SYMLINK_FOR_BINARY:=false|g" -i "${md_build}/build/custom.mk"
}

function build_openmsx() {
    rpSwap on 2000
    ./configure
    make clean
    make
    rpSwap off
    md_ret_require="${md_build}/derived/${md_id}"
}

function install_openmsx() {
    make install
    mkdir -p "${md_inst}/share/systemroms/"
    downloadAndExtract "${__archive_url}/openmsxroms.tar.gz" "${md_inst}/share/systemroms/"
}

function configure_openmsx() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/msx/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        # Set Default Config File
        local config
        config="$(mktemp)"
        echo "$(_default_settings_openmsx)" > "${config}"

        mkUserDir "${arpdir}/${md_id}/share"
        mkUserDir "${arpdir}/${md_id}/share/scripts"
        mkUserDir "${arpdir}/${md_id}/share/systemroms"

        moveConfigDir "${arpdir}/${md_id}/share/systemroms" "${biosdir}/${md_id}"

        copyDefaultConfig "${config}" "${md_conf_root}/msx/${md_id}/share/settings.xml"
        rm "${config}"

        # Copy Launcher Script
        cp "${md_data}/archypie-init.tcl" "${arpdir}/${md_id}/share/scripts"
        chown -R "${user}:${user}" "${arpdir}/${md_id}/share/scripts"
    fi

    mkRomDir "msx"
    mkRomDir "msx2"

    addEmulator 1 "${md_id}" "msx" "${md_inst}/bin/${md_id} %ROM%"
    addEmulator 1 "${md_id}-msx2" "msx2" "${md_inst}/bin/${md_id} -machine 'Boosted_MSX2_EN' %ROM%"
    addEmulator 0 "${md_id}-msx2-plus" "msx2" "${md_inst}/bin/${md_id} -machine 'Boosted_MSX2+_JP' %ROM%"
    addEmulator 0 "${md_id}-msx-turbor" "msx" "${md_inst}/bin/${md_id} -machine 'Panasonic_FS-A1GT' %ROM%"

    addSystem "msx"
    addSystem "msx2"
}

function _default_settings_openmsx() {
    local header
    local body
    local conf_reverse

    read -r -d '' header <<_EOF_
<!DOCTYPE settings SYSTEM 'settings.dtd'>
<settings>
  <settings>
    <setting id="default_machine">C-BIOS_MSX</setting>
    <setting id="osd_disk_path">${romdir}/msx</setting>
    <setting id="osd_rom_path">${romdir}/msx</setting>
    <setting id="osd_tape_path">${romdir}/msx</setting>
    <setting id="osd_hdd_path">${romdir}/msx</setting>
    <setting id="fullscreen">true</setting>
    <setting id="save_settings_on_exit">false</setting>
_EOF_

    ! isPlatform "x86" && conf_reverse="    <setting id=\"auto_enable_reverse\">off</setting\n"
    echo -e "${header}${body}${conf_reverse}  </settings>\n</settings>"
}
