#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="openmsx"
rp_module_desc="OpenMSX - Microsoft MSX, MSX2, MSX2+ & TurboR Emulator"
rp_module_help="ROM Extensions: .cas .col .dsk .mx1 .mx2 .rom .zip\n\nCopy your MSX/MSX2 games to $romdir/msx\nCopy the BIOS files to $biosdir/openmsx"
rp_module_licence="GPL2 https://raw.githubusercontent.com/openMSX/openMSX/master/doc/GPL.txt"
rp_module_repo="git https://github.com/openMSX/openMSX.git :_get_branch_openmsx"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_openmsx() {
    download https://api.github.com/repos/openMSX/openMSX/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_openmsx() {
    local depends=(
        'alsa-lib' 
        'libtheora' 
        'libvorbis' 
        'python'
        'sdl2_ttf' 
        'tcl'
    )
    isPlatform "x11" && depends+=('glew')
    getDepends "${depends[@]}"
}

function sources_openmsx() {
    gitPullOrClone
    sed -i "s|INSTALL_BASE:=/opt/openMSX|INSTALL_BASE:=$md_inst|" build/custom.mk
    sed -i "s|SYMLINK_FOR_BINARY:=true|SYMLINK_FOR_BINARY:=false|" build/custom.mk
    sed -i "s|<SDL_ttf.h>|<SDL2/SDL_ttf.h>|" build/libraries.py
    echo "LINK_FLAGS:=-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now,-lrt" >> build/custom.mk
}

function build_openmsx() {
    rpSwap on 2000
    ./configure
    make clean
    make
    rpSwap off
    md_ret_require="$md_build/derived/openmsx"
}

function install_openmsx() {
    make install
    mkdir -p "$md_inst/share/systemroms/"
    downloadAndExtract "$__archive_url/openmsxroms.tar.gz" "$md_inst/share/systemroms/"
}

function configure_openmsx() {
    mkRomDir "msx"
    mkRomDir "msx2"

    addEmulator 0 "$md_id" "msx" "$md_inst/bin/openmsx %ROM%"
    addEmulator 0 "$md_id-msx2" "msx2" "$md_inst/bin/openmsx -machine 'Boosted_MSX2_EN' %ROM%"
    addEmulator 0 "$md_id-msx2-plus" "msx2" "$md_inst/bin/openmsx -machine 'Boosted_MSX2+_JP' %ROM%"
    addEmulator 0 "$md_id-msx-turbor" "msx" "$md_inst/bin/openmsx -machine 'Panasonic_FS-A1GT' %ROM%"
    addSystem "msx"
    addSystem "msx2"

    [[ $md_mode == "remove" ]] && return

    # Add a minimal configuration
    local config="$(mktemp)"
    echo "$(_default_settings_openmsx)" > "$config"

    mkUserDir "$home/.openMSX/share/scripts"
    mkUserDir "$home/.openMSX/share/systemroms"
    moveConfigDir "$home/.openMSX" "$configdir/msx/openmsx"
    moveConfigDir "$configdir/msx/openmsx/share/systemroms" "$home/ArchyPie/BIOS/openmsx"

    copyDefaultConfig "$config" "$home/.openMSX/share/settings.xml"
    rm "$config"

    # Add an autostart script, used for joypad configuration
    cp "$md_data/archypie-init.tcl" "$home/.openMSX/share/scripts"
    chown -R "${user}:${user}" "$home/.openMSX/share/scripts"
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
    <setting id="osd_disk_path">$romdir/msx</setting>
    <setting id="osd_rom_path">$romdir/msx</setting>
    <setting id="osd_tape_path">$romdir/msx</setting>
    <setting id="osd_hdd_path">$romdir/msx</setting>
    <setting id="fullscreen">true</setting>
    <setting id="save_settings_on_exit">false</setting>
_EOF_

    ! isPlatform "x86" && conf_reverse="    <setting id=\"auto_enable_reverse\">off</setting\n"
    echo -e "${header}${body}${conf_reverse}  </settings>\n</settings>"
}
