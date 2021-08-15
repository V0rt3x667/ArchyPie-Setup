#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="b-em"
rp_module_desc="B-em - Acorn BBC Micro A, B, B+, Master 128, 512, Compact & Turbo Emulator"
rp_module_help="ROM Extension: .adf .adl .csw .dsd .fdi .img .ssd .uef\n\nCopy Your BBC Micro & Master ROMs to: $romdir/bbcmicro"
rp_module_licence="GPL2 https://raw.githubusercontent.com/stardot/b-em/master/COPYING"
rp_module_repo="git https://github.com/stardot/b-em master"
rp_module_section="emulators"
rp_module_flags=""

function sources_b-em() {
    gitPullOrClone
    downloadAndExtract "https://github.com/liballeg/allegro5/archive/refs/tags/5.2.7.0.tar.gz" "$md_build/allegro" --strip-components 1
}

function _build_allegro_b-em() {
    # Build Allegro From Source.
    # The Official Arch Linux Package is Missing allegro_native_dialog.h and liballegro_dialog.so.
    mkdir "$md_build/allegro/build"
    cd "$md_build/allegro/build"
    cmake .. \
        -DCMAKE_INSTALL_PREFIX="" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON
    make DESTDIR="$md_build/allegro-5" install
}


function build_b-em() {
    _build_allegro_b-em

    cd "$md_build"
    export CFLAGS="${CFLAGS} -ffile-prefix-map=\"$PWD\"=. -I$md_build/allegro-5/include"
    export LDFLAGS="${LDFLAGS} -Wl,-L$md_build/allegro-5/lib,-rpath='$md_inst/lib'"
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
        'allegro-5/lib'
    )
}

function configure_b-em() {
    mkRomDir "bbcmicro"

    moveConfigDir "$home/.config/b-em" "$md_conf_root/bbcmicro"

    addEmulator 1 "$md_id-modelb" "bbcmicro" "$md_inst/b-em %ROM% -m3 -autoboot"
    addEmulator 0 "$md_id-modela" "bbcmicro" "$md_inst/b-em %ROM% -m0 -autoboot"
    addEmulator 0 "$md_id-bplus" "bbcmicro" "$md_inst/b-em %ROM% -m9 -autoboot"
    addEmulator 0 "$md_id-master128" "bbcmicro" "$md_inst/b-em %ROM% -m10 -autoboot"
    addEmulator 0 "$md_id-master512" "bbcmicro" "$md_inst/b-em %ROM% -m11 -autoboot"
    addEmulator 0 "$md_id-masterturbo" "bbcmicro" "$md_inst/b-em %ROM% -m12 -autoboot"
    addEmulator 0 "$md_id-mastercompact" "bbcmicro" "$md_inst/b-em %ROM% -m13 -autoboot"
    addSystem "bbcmicro"
}
