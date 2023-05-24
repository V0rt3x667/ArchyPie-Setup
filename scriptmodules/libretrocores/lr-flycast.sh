#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-flycast"
rp_module_desc="Sega Dreamcast, Naomi, Naomi 2 & Sammy Atomiswave Libretro Core"
rp_module_help="ROM Extensions: .7z .bin .cdi .chd .cue .dat .elf .gdi .lst .m3u .zip \n\nCopy Dreamcast ROMs To: ${romdir}/dreamcast \n\nCopy Atomiswave ROMs To: ${romdir}/atomiswave \n\nCopy Naomi ROMs To: ${romdir}/naomi \n\nCopy Naomi2 ROMs To: ${romdir}/naomi2 \n\nCopy Dreamcast BIOS File (dc_boot.bin) To: ${biosdir}/dreamcast/dc \n\nCopy Naomi, Naomi2 & Atomiswave BIOS Files (awbios.zip, naomi.zip & naomi2.zip) To: ${biosdir}/dreamcast/dc/"
rp_module_licence="GPL2 https://raw.githubusercontent.com/flyinghead/flycast/master/LICENSE"
rp_module_repo="git https://github.com/flyinghead/flycast master"
rp_module_section="opt"
rp_module_flags=""

function depends_lr-flycast() {
    local depends=(
        'cmake'
        'ninja'
        'libzip'
        'zlib'
    )
    isPlatform "x11" && depends+=('libgl')

    getDepends "${depends[@]}"
}

function sources_lr-flycast() {
    gitPullOrClone
}

function build_lr-flycast() {
    local params=()

    isPlatform "gles" && ! isPlatform "gles3" && params+=("-DUSE_GLES2=ON")
    isPlatform "gles3" && params+=("-DUSE_GLES=ON")
    ! isPlatform "x86" && params+=("-DUSE_VULKAN=OFF")

    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DLIBRETRO="ON" \
        -DUSE_HOST_LIBZIP="ON" \
        "${params[@]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build

    md_ret_require="${md_build}/build/flycast_libretro.so"
}

function install_lr-flycast() {
    md_ret_files=('build/flycast_libretro.so')
}

function configure_lr-flycast() {
    local systems=(
        'arcade'
        'atomiswave'
        'dreamcast'
        'naomi'
        'naomi2'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
        done

        mkUserDir "${biosdir}/dreamcast"
        mkUserDir "${biosdir}/dreamcast/dc"
    fi

    for system in "${systems[@]}"; do
        local def=1
        if [[ "${system}" == "arcade" ]]; then
            def=0
        fi

        defaultRAConfig "${system}" "system_directory" "${biosdir}/dreamcast"
        addEmulator "${def}" "${md_id}" "${system}" "${md_inst}/flycast_libretro.so"
        addSystem "${system}"
    done
}
