#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="zesarux"
rp_module_desc="ZEsarUX - Sinclair Zx80, Zx81, Z88, Zx Spectrum 16, 48, 128, +2, +2A & ZX-Uno Emulator"
rp_module_help="ROM Extensions: .sna .szx .z80 .tap .tzx .gz .udi .mgt .img .trd .scl .dsk .zip\n\nCopy your ZX Spectrum games to $romdir/zxspectrum"
rp_module_licence="GPL3 https://raw.githubusercontent.com/chernandezba/zesarux/master/src/LICENSE"
rp_module_repo="git https://github.com/chernandezba/zesarux.git :_get_branch_zesarux"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_zesarux() {
    download https://api.github.com/repos/chernandezba/zesarux/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_zesarux() {
    local depends=(
        'aalib'
        'alsa-lib'
        'openssl'
    )
    isPlatform "x11" && depends+=('libpulse' 'libxxf86vm')
    #if isPlatform "videocore"; then
    #    depends+=('sdl')
    #else
        depends+=('sdl2')
    #fi
    getDepends "${depends[@]}"
}

function sources_zesarux() {
    gitPullOrClone
}

function build_zesarux() {
    local params=()
    isPlatform "rpi" && params+=(--enable-raspberry)
    ! isPlatform "x11" && params+=(--disable-pulse)
    ! isPlatform "rpi" && params+=(--enable-sdl2)

    cd src
    ./configure \
        --prefix "$md_inst" \
        --disable-caca \
        --enable-ssl \
        --enable-memptr \
        --enable-visualmem \
        --enable-cpustats \
        "${params[@]}"
    make clean
    make
    md_ret_require="$md_build/src/zesarux"
}

function install_zesarux() {
    cd src
    make install
}


function configure_zesarux() {
    mkRomDir "zxspectrum"
    mkRomDir "amstradcpc"
    mkRomDir "samcoupe"

    mkUserDir "$md_conf_root/zxspectrum"

    cat > "$romdir/zxspectrum/+Start ZEsarUX.sh" << _EOF_
#!/bin/bash
"$md_inst/bin/zesarux" "\$@"
_EOF_
    chmod +x "$romdir/zxspectrum/+Start ZEsarUX.sh"
    chown "${user}:${user}" "$romdir/zxspectrum/+Start ZEsarUX.sh"

    moveConfigFile "$home/.zesaruxrc" "$md_conf_root/zxspectrum/.zesaruxrc"

    local ao="sdl"
    isPlatform "x11" && ao="pulse"
    local config="$(mktemp)"

    cat > "$config" << _EOF_
;ZEsarUX sample configuration file
;
;Lines beginning with ; or # are ignored

;Run zesarux with --help or --experthelp to see all the options
--disableborder
--disablefooter
--vo sdl
--ao $ao
--hidemousepointer
--fullscreen

--smartloadpath $romdir/zxspectrum

--joystickemulated Kempston

;Remap Fire Event. Uncomment and amend if you wish to change the default button 3.
;--joystickevent 3 Fire
;Remap On-screen keyboard. Uncomment and amend if you wish to change the default button 5.
;--joystickevent 5 Osdkeyboard
_EOF_

    copyDefaultConfig "$config" "$md_conf_root/zxspectrum/.zesaruxrc"
    rm "$config"

    addEmulator 1 "$md_id" "zxspectrum" "bash $romdir/zxspectrum/+Start\ ZEsarUX.sh %ROM%"
    addEmulator 1 "$md_id" "samcoupe" "bash $romdir/zxspectrum/+Start\ ZEsarUX.sh --machine sam %ROM%"
    addEmulator 1 "$md_id" "amstradcpc" "bash $romdir/zxspectrum/+Start\ ZEsarUX.sh --machine CPC464 %ROM%"
    addSystem "zxspectrum"
    addSystem "samcoupe"
    addSystem "amstradcpc"
}
