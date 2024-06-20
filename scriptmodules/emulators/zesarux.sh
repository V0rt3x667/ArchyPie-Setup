#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="zesarux"
rp_module_desc="ZEsarUX: Sinclair Zx80, Zx81, Z88, Zx Spectrum 16, 48, 128, +2, +2A & ZX-Uno Emulator"
rp_module_help="ROM Extensions: .dsk .gz .img .mgt .scl .sna .szx .tap .trd .tzx .udi .z80 .zip\n\nCopy ZX Spectrum Games To: ${romdir}/zxspectrum"
rp_module_licence="GPL3 https://raw.githubusercontent.com/chernandezba/zesarux/master/src/LICENSE"
rp_module_repo="git https://github.com/chernandezba/zesarux :_get_branch_zesarux"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_zesarux() {
    download "https://api.github.com/repos/chernandezba/zesarux/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_zesarux() {
    local depends=(
        'aalib'
        'alsa-lib'
        'libcaca'
        'openssl'
        'sdl2'
    )

    isPlatform "x11" && depends+=('libpulse' 'libxxf86vm')

    getDepends "${depends[@]}"
}

function sources_zesarux() {
    gitPullOrClone

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"
}

function build_zesarux() {
    local params=()

    isPlatform "kms" && params+=(
        '--disable-xext'
        '--disable-xvidmode'
        '--disable-xwindows'
    )
    ! isPlatform "x11" && params+=(--disable-pulse)

    cd src || exit
    ./configure \
        --prefix "${md_inst}" \
        --enable-sdl2 \
        --enable-ssl \
        --disable-fbdev \
        "${params[@]}"
    make clean
    make
    md_ret_require="${md_build}/src/${md_id}"
}

function install_zesarux() {
    cd src || exit
    make install
    md_ret_require="${md_inst}/bin/${md_id}"
}

function configure_zesarux() {
    local systems=(
        'amstradcpc'
        'samcoupe'
        'zxspectrum'
    )

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/zxspectrum/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
        done

        # Create Launcher Script
        cat > "${romdir}/zxspectrum/+Start ZEsarUX.sh" << _EOF_
#!/bin/bash
"${md_inst}/bin/${md_id}" "\${@}"
_EOF_
        chmod +x "${romdir}/zxspectrum/+Start ZEsarUX.sh"
        chown "${user}:${user}" "${romdir}/zxspectrum/+Start ZEsarUX.sh"

        # Create Default Config File
        local ao="sdl"
        local config
        isPlatform "x11" && ao="pulse"
        config="$(mktemp)"

        cat > "${config}" << _EOF_
;ZEsarUX sample configuration file
;
;Lines beginning with ; or # are ignored

;Run zesarux with --help or --experthelp to see all the options
--disableborder
--disablefooter
--vo sdl
--ao ${ao}
--hidemousepointer
--fullscreen

--smartloadpath "${romdir}/zxspectrum"

--joystickemulated Kempston

;Remap Fire Event. Uncomment and amend if you wish to change the default button 3.
;--joystickevent 3 Fire
;Remap On-screen keyboard. Uncomment and amend if you wish to change the default button 5.
;--joystickevent 5 Osdkeyboard
_EOF_
        copyDefaultConfig "${config}" "${md_conf_root}/zxspectrum/${md_id}/zesaruxrc"
        rm "${config}"
    fi

    addEmulator 1 "${md_id}" "zxspectrum" "bash ${romdir}/zxspectrum/+Start\ ZEsarUX.sh %ROM%"
    addEmulator 1 "${md_id}" "samcoupe"   "bash ${romdir}/zxspectrum/+Start\ ZEsarUX.sh --machine Sam %ROM%"
    addEmulator 1 "${md_id}" "amstradcpc" "bash ${romdir}/zxspectrum/+Start\ ZEsarUX.sh --machine CPC464 %ROM%"

    for system in "${systems[@]}"; do
        addSystem "${system}"
    done
}
