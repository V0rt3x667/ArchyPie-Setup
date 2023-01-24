#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="vice"
rp_module_desc="VICE: Commodore C64, C64DTV, C128, VIC20, PET, PLUS4 & CBM-II Emulator"
rp_module_help="ROM Extensions: .crt .d64 .g64 .prg .t64 .tap .vsf .x64 .zip\n\nCopy Commodore 64 Games To: ${romdir}/c64"
rp_module_licence="GPL2 https://raw.githubusercontent.com/VICE-Team/svn-mirror/main/vice/COPYING"
rp_module_repo="git https://github.com/VICE-Team/svn-mirror :_get_branch_vice"
rp_module_section="opt"
rp_module_flags="!wayland xwayland"

function _get_branch_vice() {
    download "https://api.github.com/repos/VICE-Team/svn-mirror/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_vice() {
    local depends=(
        'alsa-lib'
        'dos2unix'
        'ffmpeg4.4'
        'flac'
        'libjpeg'
        'libpcap'
        'libpng'
        'libvorbis'
        'libxaw'
        'mpg123'
        'pciutils'
        'portaudio'
        'sdl2_image'
        'sdl2'
        'xa'
    )
    isPlatform "x11" || ! isPlatform "wayland" && depends+=('libpulse')
    getDepends "${depends[@]}"
}

function sources_vice() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|ARCHDEP_XDG_CONFIG_HOME \".config\"|ARCHDEP_XDG_CONFIG_HOME \"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/${md_id}/src/arch/shared/archdep_defs.h"

    sed -e "s|lib64|lib|g" -i "${md_build}/${md_id}/configure.ac"
}

function build_vice() {
    cd "${md_build}/${md_id}"

    local params=(
        '--disable-pdf-docs'
        '--enable-ethernet'
        '--enable-external-ffmpeg'
        '--enable-sdlui2'
        '--enable-x64'
        '--with-fastsid'
        '--without-oss'
        '--libdir=/usr/lib'
    )
    ! isPlatform "x11" || ! isPlatform "wayland" && params+=('--disable-catweasel' '--without-pulse')
    
    export CFLAGS="${CFLAGS} -w -Wl,--allow-multiple-definition"
    PKG_CONFIG_PATH="/usr/lib/ffmpeg4.4/pkgconfig"
    ./autogen.sh
    ./configure --prefix="${md_inst}" "${params[@]}"
    make clean
    make
    md_ret_require="${md_build}/${md_id}/src/x64"
}

function install_vice() {
    cd "${md_build}/${md_id}"
    make install
    md_ret_require="${md_build}/${md_id}/bin/x64"
}

function configure_vice() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/c64"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "c64"

        # Create Launcher Script
        local exts
        exts="$(getPlatformConfig c64_exts)"

        cat > "${md_inst}/bin/${md_id}.sh" << _EOF_
#!/bin/bash

BIN="\${0%/*}/\$1"
ROM="\$2"
PARAMS=("\${@:3}")

romdir="\${ROM%/*}"
ext="\${ROM##*.}"
source "${rootdir}/lib/archivefuncs.sh"

archiveExtract "\${ROM}" "${exts}"

# Check For Successful Extraction
if [[ \$? == 0 ]]; then
    ROM="\${arch_files[0]}"
    romdir="\${arch_dir}"
fi

"\${BIN}" -chdir "\${romdir}" "\${PARAMS[@]}" "\${ROM}"
archiveCleanup
_EOF_
        chmod +x "${md_inst}/bin/${md_id}.sh"

        # Create Default Configuration File
        local config
        config="$(mktemp)"
        iniConfig "=" "" "${config}"

        echo "[C64]" > "${config}"
        if ! isPlatform "x11" || ! isPlatform "wayland"; then
            iniSet "Mouse" "1"
            iniSet "VICIIDoubleSize" "0"
            iniSet "VICIIDoubleScan" "0"
            iniSet "VICIIFilter" "0"
            iniSet "VICIIVideoCache" "0"
            iniSet "SDLWindowWidth" "384"
            iniSet "SDLWindowHeight" "272"
        fi

        if isPlatform "arm"; then
            iniSet "SidEngine" "0"
        fi

        if isPlatform "x11" || isPlatform "kms" || isPlatform "wayland"; then
            iniSet "VICIIFullscreen" "1"
        fi

        if ! isPlatform "x11"; then
            iniDel "SDLBitdepth"
            iniSet "VICIIDoubleSize" "0"
            iniSet "VICIIDoubleScan" "0"
            iniSet "SDLWindowWidth" "384"
            iniSet "SDLWindowHeight" "272"
        fi
        copyDefaultConfig "${config}" "${md_conf_root}/c64/sdl-vicerc"
        rm "${config}"
    fi

    addEmulator 1 "${md_id}-x64" "c64" "${md_inst}/bin/${md_id}.sh x64 %ROM%"
    addEmulator 0 "${md_id}-x64dtv" "c64" "${md_inst}/bin/${md_id}.sh x64dtv %ROM%"
    addEmulator 0 "${md_id}-x64sc" "c64" "${md_inst}/bin/${md_id}.sh x64sc %ROM%"
    addEmulator 0 "${md_id}-x128" "c64" "${md_inst}/bin/${md_id}.sh x128 %ROM%"
    addEmulator 0 "${md_id}-xpet" "c64" "${md_inst}/bin/${md_id}.sh xpet %ROM%"
    addEmulator 0 "${md_id}-xplus4" "c64" "${md_inst}/bin/${md_id}.sh xplus4 %ROM%"
    addEmulator 0 "${md_id}-xvic" "c64" "${md_inst}/bin/${md_id}.sh xvic %ROM%"
    addEmulator 0 "${md_id}-xvic-cart" "c64" "${md_inst}/bin/${md_id}.sh xvic %ROM% -cartgeneric"

    addSystem "c64"
}
