#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-flycast"
rp_module_desc="Sega Dreamcast, Naomi, Naomi 2 & Sammy Atomiswave Libretro Core"
rp_module_help="ROM Extensions: .7z .bin .cdi .chd .cue .dat .elf .gdi .lst .m3u .zip\n\nCopy Dreamcast ROMs To: ${romdir}/dreamcast\n\nCopy Atomiswave ROMs To: ${romdir}/atomiswave\n\nCopy Naomi ROMs To: ${romdir}/naomi\n\nCopy Naomi2 ROMs To: ${romdir}/naomi2\n\nCopy Dreamcast, Naomi, Naomi2 & Atomiswave BIOS Files: dc_boot.bin, awbios.zip, naomi.zip & naomi2.zip To: ${biosdir}/dreamcast/dc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/flyinghead/flycast/master/LICENSE"
rp_module_repo="git https://github.com/flyinghead/flycast master"
rp_module_section="opt"
rp_module_flags=""

function depends_lr-flycast() {
    local depends=(
        'clang'
        'cmake'
        'libgl'
        'libzip'
        'lld'
        'ninja'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_lr-flycast() {
    gitPullOrClone
}

function build_lr-flycast() {
    local params=()

    if isPlatform "gles3"; then
        params+=("-DUSE_GLES=ON")
    elif isPlatform "gles2"; then
        params+=("-DUSE_GLES2=ON")
    fi
    isPlatform "vulkan" && params+=("-DUSE_VULKAN=ON") || params+=("-DUSE_VULKAN=OFF")

    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DLIBRETRO="ON" \
        -DWITH_SYSTEM_ZLIB="ON" \
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
            mkUserDir "${biosdir}/${system}"
            defaultRAConfig "${system}"
        done

        # Symlink Supported Systems BIOS Dirs To 'dreamcast/dc'
        mkUserDir "${biosdir}/dreamcast/dc"
        for system in "${systems[@]}"; do
            if [[ "${system}" != "dreamcast" ]]; then
                ln -snf "${biosdir}/dreamcast/dc" "${biosdir}/${system}/dc"
            fi
        done
    fi

    for system in "${systems[@]}"; do
        local def=1
        if [[ "${system}" == "arcade" ]]; then
            def=0
        fi
        addEmulator "${def}" "${md_id}" "${system}" "${md_inst}/flycast_libretro.so"
        addSystem "${system}"
    done
}
