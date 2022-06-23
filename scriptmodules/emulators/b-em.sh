#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="b-em"
rp_module_desc="B-em - Acorn BBC Micro A, B, B+, Master 128, 512, Compact & Turbo Emulator"
rp_module_help="ROM Extension: .adf .adl .csw .dsd .fdi .img .ssd .uef\n\nCopy Your BBC Micro & Master ROMs to: $romdir/bbcmicro"
rp_module_licence="GPL2 https://raw.githubusercontent.com/stardot/b-em/master/COPYING"
rp_module_repo="git https://github.com/stardot/b-em master"
rp_module_section="main"
rp_module_flags=""

function depends_b-em() {
    local depends=(
        'allegro'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_b-em() {
    gitPullOrClone
}

function build_b-em() {
    export CFLAGS="${CFLAGS} -ffile-prefix-map=\"$PWD\"=."
    ./autogen.sh
    ./configure --prefix="$md_inst"
    make clean
    make
    md_ret_require="$md_build/b-em"
}

function install_b-em() {
    md_ret_files=(
        'b-em'
        'b-em.cfg'
        'README.md'
        'ddnoise'
        'discs'
        'fonts'
        'roms'
        'tapes'
    )
}

function configure_b-em() {
    mkRomDir "bbcmicro"

    moveConfigDir "$home/.config/b-em" "$md_conf_root/bbcmicro/b-em"

    addEmulator 1 "$md_id-modelb" "bbcmicro" "$md_inst/b-em %ROM% -m3 -autoboot"
    addEmulator 0 "$md_id-modela" "bbcmicro" "$md_inst/b-em %ROM% -m0 -autoboot"
    addEmulator 0 "$md_id-bplus" "bbcmicro" "$md_inst/b-em %ROM% -m9 -autoboot"
    addEmulator 0 "$md_id-master128" "bbcmicro" "$md_inst/b-em %ROM% -m10 -autoboot"
    addEmulator 0 "$md_id-master512" "bbcmicro" "$md_inst/b-em %ROM% -m11 -autoboot"
    addEmulator 0 "$md_id-masterturbo" "bbcmicro" "$md_inst/b-em %ROM% -m12 -autoboot"
    addEmulator 0 "$md_id-mastercompact" "bbcmicro" "$md_inst/b-em %ROM% -m13 -autoboot"
    addSystem "bbcmicro"
}
