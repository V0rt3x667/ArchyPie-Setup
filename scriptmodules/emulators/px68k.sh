#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="px68k"
rp_module_desc="px68k: SHARP X68000 Emulator"
rp_module_help="ROM Extensions: .2hd .88d .cmd .d88 .dim .dup .hdf .hdm .img .m3u .xdf\n\nCopy X68000 Games To: ${romdir}/x68000\n\nCopy BIOS Files: cgrom.dat, iplrom.dat, iplrom30.dat, iplromco.dat & iplromxv.dat To: ${biosdir}/x68000"
rp_module_repo="git https://github.com/TurtleBazooka/px68k.git master"
rp_module_section="exp"
rp_module_flags=""

function depends_px68k() {
    local depends=(
        'fluidsynth'
        'freepats-general-midi'
        'sdl2_ttf'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_px68k() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|\".keropi\"|\"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/SDL/prop.c"
}

function build_px68k() {
    make clean
    make SDL2=1 FLUID=1

    md_ret_require="${md_build}/px68k.sdl2"
}

function install_px68k() {
    md_ret_files=(
        'px68k.sdl2'
        'readme.txt'
        'README.md'
        'version.txt'
    )
}

function configure_px68k() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/x68000/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "x68000"
        mkUserDir "${biosdir}/x68000"

        # Symlink BIOS Files
        local files=(
            'cgrom.dat'
            'iplrom.dat'
            'iplrom30.dat'
            'iplromco.dat'
            'iplromxv.dat'
        )
        for file in "${files[@]}"; do
            ln -sf "${biosdir}/x68000/${file}" "${md_conf_root}/x68000/${md_id}/${file}"
        done

        # Create A Default Config File
        local conf="${md_conf_root}/x68000/${md_id}/config"

        if [[ ! -f "${conf}" ]]; then
            cat > "${conf}" <<_EOF_
[WinX68k]
StartDir="${romdir}/x68000"
MenuLanguage=1
SoundFontFile=/usr/share/soundfonts/freepats-general-midi.sf2
_EOF_
        fi
        chown -R "${user}:${user}" "${conf}"
    fi

    addEmulator 1 "${md_id}" "x68000" "${md_inst}/px68k.sdl2 %ROM%"

    addSystem "x68000"
}
