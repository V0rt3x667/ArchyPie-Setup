#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-fbalpha2012"
rp_module_desc="Final Burn Alpha (0.2.97.30) Arcade Libretro Core"
rp_module_help="ROM Extension: .zip\n\nCopy FBA ROMs To:\n${romdir}/fba Or\n${romdir}/neogeo Or\n${romdir}/arcade\n\nCopy NeoGeo BIOS File (neogeo.zip) To Your Chosen ROM Directory."
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/fbalpha2012/master/docs/license.txt"
rp_module_repo="git https://github.com/libretro/fbalpha2012 master"
rp_module_section="opt"

function sources_lr-fbalpha2012() {
    gitPullOrClone
}

function build_lr-fbalpha2012() {
    local params=()
    isPlatform "arm" && params+=('platform=armv')

    cd svn-current/trunk/
    make -f makefile.libretro clean
    make -f makefile.libretro "${params[@]}"

    md_ret_require="${md_build}/svn-current/trunk/fbalpha2012_libretro.so"
}

function install_lr-fbalpha2012() {
    md_ret_files=(
        'svn-current/trunk/fba.chm'
        'svn-current/trunk/fbalpha2012_libretro.so'
        'svn-current/trunk/gamelist-gx.txt'
        'svn-current/trunk/gamelist.txt'
        'svn-current/trunk/preset-example.zip'
        'svn-current/trunk/whatsnew.html'
    )
}

function configure_lr-fbalpha2012() {
    local system
    for system in arcade fba neogeo; do
        mkRomDir "${system}"
        defaultRAConfig "${system}"
        addEmulator 0 "${md_id}" "${system}" "${md_inst}/fbalpha2012_libretro.so"
        addSystem "${system}"
    done
}
