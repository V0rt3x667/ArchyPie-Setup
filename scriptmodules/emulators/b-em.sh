#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="b-em"
rp_module_desc="B-em: Acorn BBC Micro A, B, B+, Master 128, 512, Compact & Turbo Emulator"
rp_module_help="ROM Extension: .adf .adl .csw .dsd .fdi .img .ssd .uef\n\nCopy BBC Micro & Master Games To: ${romdir}/bbcmicro"
rp_module_licence="GPL2 https://raw.githubusercontent.com/stardot/b-em/master/COPYING"
rp_module_repo="git https://github.com/stardot/b-em.git master"
rp_module_section="main"
rp_module_flags="!all x11 xwayland"

function depends_b-em() {
    local depends=(
        'allegro'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_b-em() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|(path, \".config\");|(path, \"ArchyPie/configs\");|g" -i "${md_build}/src/linux.c"
}

function build_b-em() {
    export CFLAGS="${CFLAGS} -ffile-prefix-map=\"${PWD}\"=."
    ./autogen.sh
    ./configure --prefix="${md_inst}"
    make clean
    make
    md_ret_require="${md_build}/${md_id}"
}

function install_b-em() {
    md_ret_files=(
        'b-em.cfg'
        'b-em'
        'ddnoise'
        'discs'
        'fonts'
        'README.md'
        'roms'
        'tapes'
    )
}

function configure_b-em() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "bbcmicro"
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/bbcmicro/${md_id}/"

    addEmulator 1 "${md_id}-modelb" "bbcmicro" "${md_inst}/${md_id} %ROM% -m3 -autoboot"
    addEmulator 0 "${md_id}-modela" "bbcmicro" "${md_inst}/${md_id} %ROM% -m0 -autoboot"
    addEmulator 0 "${md_id}-bplus" "bbcmicro" "${md_inst}/${md_id} %ROM% -m9 -autoboot"
    addEmulator 0 "${md_id}-master128" "bbcmicro" "${md_inst}/${md_id} %ROM% -m10 -autoboot"
    addEmulator 0 "${md_id}-master512" "bbcmicro" "${md_inst}/${md_id} %ROM% -m11 -autoboot"
    addEmulator 0 "${md_id}-masterturbo" "bbcmicro" "${md_inst}/${md_id} %ROM% -m12 -autoboot"
    addEmulator 0 "${md_id}-mastercompact" "bbcmicro" "${md_inst}/${md_id} %ROM% -m13 -autoboot"

    addSystem "bbcmicro"
}
