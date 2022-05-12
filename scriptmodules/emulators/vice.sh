#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="vice"
rp_module_desc="VICE - Commodore C64, C64DTV, C128, VIC20, PET, PLUS4 & CBM-II Emulator"
rp_module_help="ROM Extensions: .crt .d64 .g64 .prg .t64 .tap .x64 .zip .vsf\n\nCopy your Commodore 64 games to $romdir/c64"
rp_module_licence="GPL2 https://raw.githubusercontent.com/VICE-Team/svn-mirror/main/vice/COPYING"
rp_module_repo="git https://github.com/VICE-Team/svn-mirror.git :_get_branch_vice"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_vice() {
    download https://api.github.com/repos/VICE-Team/svn-mirror/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_vice() {
    local depends=(
        'alsa-lib'
        'dos2unix'
        'ffmpeg'
        'flac'
        'libjpeg'
        'mpg123'
        'libpcap' 
        'libpng'
        'libvorbis'
        'libxaw'
        'pciutils'
        'portaudio'
        'sdl2'
        'sdl2_image'
        'xa'
    )
    isPlatform "x11" && depends+=('libpulse')
    getDepends "${depends[@]}"
}

function sources_vice() {
    gitPullOrClone
}

function build_vice() {
    cd "$md_build/vice"
    local params=(
        --disable-pdf-docs
        --enable-ethernet
        --enable-external-ffmpeg
        --enable-sdlui2
        --enable-x64
        --with-fastsid
        --without-oss
    )
    ! isPlatform "x11" && params+=(--disable-catweasel --without-pulse)
    ./autogen.sh
    ./configure --prefix="$md_inst" "${params[@]}"
    make clean
    make
    md_ret_require="$md_build/vice/src/x64"
}

function install_vice() {
    cd "$md_build/vice"
    make install
}

function configure_vice() {
    # get a list of supported extensions
    local exts="$(getPlatformConfig c64_exts)"

    # install the vice start script
    mkdir -p "$md_inst/bin"
    cat > "$md_inst/bin/vice.sh" << _EOF_
#!/bin/bash

BIN="\${0%/*}/\$1"
ROM="\$2"
PARAMS=("\${@:3}")

romdir="\${ROM%/*}"
ext="\${ROM##*.}"
source "$rootdir/lib/archivefuncs.sh"

archiveExtract "\$ROM" "$exts"

# check successful extraction and if we have at least one file
if [[ \$? == 0 ]]; then
    ROM="\${arch_files[0]}"
    romdir="\$arch_dir"
fi

"\$BIN" -chdir "\$romdir" "\${PARAMS[@]}" "\$ROM"
archiveCleanup
_EOF_

    chmod +x "$md_inst/bin/vice.sh"

    mkRomDir "c64"

    addEmulator 1 "$md_id-x64" "c64" "$md_inst/bin/vice.sh x64 %ROM%"
    addEmulator 0 "$md_id-x64dtv" "c64" "$md_inst/bin/vice.sh x64dtv %ROM%"
    addEmulator 0 "$md_id-x64sc" "c64" "$md_inst/bin/vice.sh x64sc %ROM%"
    addEmulator 0 "$md_id-x128" "c64" "$md_inst/bin/vice.sh x128 %ROM%"
    addEmulator 0 "$md_id-xpet" "c64" "$md_inst/bin/vice.sh xpet %ROM%"
    addEmulator 0 "$md_id-xplus4" "c64" "$md_inst/bin/vice.sh xplus4 %ROM%"
    addEmulator 0 "$md_id-xvic" "c64" "$md_inst/bin/vice.sh xvic %ROM%"
    addEmulator 0 "$md_id-xvic-cart" "c64" "$md_inst/bin/vice.sh xvic %ROM% -cartgeneric"
    addSystem "c64"

    [[ "$md_mode" == "remove" ]] && return

    # copy configs and symlink the old and new config folders to $md_conf_root/c64/
    moveConfigDir "$home/.vice" "$md_conf_root/c64"
    moveConfigDir "$home/.config/vice" "$md_conf_root/c64"

    local config="$(mktemp)"
    echo "[C64]" > "$config"
    iniConfig "=" "" "$config"
    if ! isPlatform "x11"; then
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

    if isPlatform "x11" || isPlatform "kms"; then
        iniSet "VICIIFullscreen" "1"
    fi

    copyDefaultConfig "$config" "$md_conf_root/c64/sdl-vicerc"
    rm "$config"

    if ! isPlatform "x11"; then
        # enforce a few settings to ensure a smooth upgrade from sdl1
        iniConfig "=" "" "$md_conf_root/c64/sdl-vicerc"
        iniDel "SDLBitdepth"
        iniSet "VICIIDoubleSize" "0"
        iniSet "VICIIDoubleScan" "0"
        iniSet "SDLWindowWidth" "384"
        iniSet "SDLWindowHeight" "272"
    fi
}
