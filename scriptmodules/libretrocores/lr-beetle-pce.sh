#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-pce"
rp_module_desc="NEC PC Engine (TurboGrafx-16), PC Engine CD (TurboGrafx-CD) & PC Engine SuperGrafx Libretro Core"
rp_module_help="ROM Extensions: .ccd .chd .cue .m3u .pce .sgx .toc\n\nCopy NEC PC Engine (TurboGrafx-16) ROMs To: ${romdir}/pcengine\n\nCopy PC Engine CD (TurboGrafx-CD) Games To: ${romdir}/pce-cd\n\nCopy PC Engine SuperGrafx ROMs To Either: ${romdir}/pcengine\n${romdir}/supergrafx\n\nCopy BIOS File: syscard3.pce To: ${biosdir}/pcengine"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-pce-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-pce-libretro master"
rp_module_section="main"

function sources_lr-beetle-pce() {
    gitPullOrClone
}

function build_lr-beetle-pce() {
    make clean
    make
    md_ret_require="${md_build}/mednafen_pce_libretro.so"
}

function install_lr-beetle-pce() {
    md_ret_files=('mednafen_pce_libretro.so')
}

function configure_lr-beetle-pce() {
    local systems=(
        'pce-cd'
        'pcengine'
        'supergrafx'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            defaultRAConfig "${system}"
        done

        # Symlink Supported Systems BIOS Dirs To 'pcengine'
        mkUserDir "${biosdir}/pcengine"
        for system in "${systems[@]}"; do
            if [[ "${system}" != "pcengine" ]]; then
                ln -sf "${biosdir}/pcengine" "${biosdir}/${system}"
            fi
        done

        setRetroArchCoreOption "pce_aspect_ratio" "4:3"
        setRetroArchCoreOption "pce_multitap" "disabled"
        setRetroArchCoreOption "pce_scaling" "hires"
    fi

    for system in "${systems[@]}"; do
        addEmulator 1 "${md_id}" "${system}" "${md_inst}/mednafen_pce_libretro.so"
        addSystem "${system}"
    done
}
