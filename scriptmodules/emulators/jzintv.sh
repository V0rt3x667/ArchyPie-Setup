#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="jzintv"
rp_module_desc="jzIntv: Mattel Electronics Intellivision Emulator"
rp_module_help="ROM Extensions: .bin .int .rom\n\nCopy Intellivision ROMs To: ${romdir}/intellivision\n\nCopy BIOS Files:\n\nexec.bin\n\ngrom.bin\n\nTo: ${biosdir}/intellivision"
rp_module_licence="GPL2 http://spatula-city.org/%7Eim14u2c/intv"
rp_module_repo="file ${__archive_url}/jzintv-20200712-src.zip"
rp_module_section="opt"
rp_module_flags=""

function depends_jzintv() {
    local depends=(
        'ncurses'
        'readline'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_jzintv() {
    rm -rf "${md_build}/${md_id}"

    downloadAndExtract "${md_repo_url}" "${md_build}"

    # jzintv-YYYYMMDD/ --> jzintv/
    mv "${md_id}"-[0-9]* "${md_id}"

    cd "${md_id}/src" || exit

    # Add Source Release Date Information To Build
    mv buildcfg/90-svn.mak buildcfg/90-svn.mak.txt
    echo "SVN_REV := $(echo ${md_repo_url} | grep -o -P '[\d]{8}')" > buildcfg/90-src_releasedate.mak
    sed -i.zip-dist "s/SVN Revision/Releasedate/" svn_revision.c

    # 'aarch64' Does Not Include 'sys/io.h' But It's Not Needed So Remove
    grep -rl "include.*sys/io.h" | xargs sed -i "/include.*sys\/io.h/d"

    # Remove Shipped Binaries & Libraries
    rm -rf ../bin

    # Fix Linker Flags
    sed -e "s|SLFLAGS ?= -static \$(LFLAGS)|SLFLAGS ?= \$(LFLAGS)|g" -i ./Makefile.common
    sed -e "s|RL_LFLAGS = -lreadline -ltermcap|RL_LFLAGS = -lreadline|g" -i ./Makefile
    sed -e "s|RL_LFLAGS = -lreadline -ltermcap|RL_LFLAGS = -lreadline|g" -i ./Makefile.linux_sdl2
}

function build_jzintv() {
    mkdir -p "${md_id}/bin"
    cd "${md_id}/src" || exit

    make clean
    make LTO="" OPT_FLAGS=""

    md_ret_require="${md_build}/${md_id}/bin/${md_id}"
}

function install_jzintv() {
    md_ret_files=(
        "${md_id}/bin"
        "${md_id}/doc"
        "${md_id}/src/COPYING.txt"
        "${md_id}/src/COPYRIGHT.txt"
        $(find ${md_id}/Release*)
    )
}

function configure_jzintv() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "intellivision"
        mkUserDir "${biosdir}/intellivision"
    fi

    local params=(
        --displaysize="%XRES%x%YRES%"
        --quiet
        --rom-path="${biosdir}/intellivision"
        --voice=1
        --fullscreen=1
    )

    addEmulator 1 "${md_id}" "intellivision" "${md_inst}/bin/${md_id} ${params[*]} %ROM%"
    addEmulator 0 "${md_id}-ecs" "intellivision" "${md_inst}/bin/${md_id} ${params[*]} --ecs=1 %ROM%"

    addSystem "intellivision"
}
