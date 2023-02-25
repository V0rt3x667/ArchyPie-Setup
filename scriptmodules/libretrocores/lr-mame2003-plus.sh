#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mame2003-plus"
rp_module_desc="MAME 0.78 Enhanced Libretro Core"
rp_module_help="ROM Extension: .zip\n\nCopy MAME ROMs To:\n${romdir}/mame-libretro\nOr\n${romdir}/arcade"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/mame2003-plus-libretro/master/LICENSE.md"
rp_module_repo="git https://github.com/libretro/mame2003-plus-libretro master"
rp_module_section="opt"

function sources_lr-mame2003-plus() {
    gitPullOrClone
}

function build_lr-mame2003-plus() {
    rpSwap on 750
    make clean
    local params=()
    isPlatform "arm" && params+=("ARM=1")
    make ARCH="${CFLAGS}" "${params[@]}"
    rpSwap off
    md_ret_require="${md_build}/mame2003_plus_libretro.so"
}

function install_lr-mame2003-plus() {
    md_ret_files=(
        'mame2003_plus_libretro.so'
        'metadata'
    )
}

function configure_lr-mame2003-plus() {
    if [[ "${md_mode}" == "install" ]]; then
        local core_name="mame2003-plus"
        local mame_dir=('arcade' 'mame-libretro')
        local mame_sub_dir=('cfg' 'ctrlr' 'diff' 'hi' 'memcard' 'nvram')
        for dir in "${mame_dir[@]}"; do
            mkRomDir "${dir}"
            mkRomDir "${dir}/${core_name}"
            for sub_dir in "${mame_sub_dir[@]}"; do
            mkRomDir "${dir}/${core_name}/${sub_dir}"
            done
        done

        mkUserDir "${biosdir}/${core_name}"
        mkUserDir "${biosdir}/${core_name}/samples"
        mkUserDir "${biosdir}/${core_name}/artwork"

        # Copy hiscore.dat, cheat.dat & artwork
        cp -rv "${md_inst}/metadata/"{cheat.dat,hiscore.dat} "${biosdir}/${core_name}/"
        cp "${md_inst}/metadata/artwork/"* "${biosdir}/${core_name}/artwork/"
        chown -R "${user}:${user}" "${biosdir}/${core_name}"
    fi

    setRetroArchCoreOption "${core_name}_skip_disclaimer" "enabled"

    defaultRAConfig "arcade"
    defaultRAConfig "mame-libretro"

    addEmulator 0 "${md_id}" "arcade" "${md_inst}/mame2003_plus_libretro.so"
    addEmulator 1 "${md_id}" "mame-libretro" "${md_inst}/mame2003_plus_libretro.so"

    addSystem "arcade"
    addSystem "mame-libretro"
}
