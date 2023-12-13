#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-swanstation"
rp_module_desc="Sony Playstation Libretro Core"
rp_module_help="ROM Extensions: .bin .chd .cue .ecm .exe .img .iso .m3u .mds .pbp .psexe .psf\n\nCopy PlayStation ROMs To: ${romdir}/psx\n\nCopy BIOS Files: scph5500.bin, scph5501.bin & scph5502.bin To: ${biosdir}/psx"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/swanstation/main/LICENSE"
rp_module_repo="git https://github.com/libretro/swanstation main"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-swanstation() {
    local depends=(
        'clang'
        'cmake'
        'lld'
        'ninja'
    )
    getDepends "${depends[@]}"
}

function sources_lr-swanstation() {
    gitPullOrClone
}

function build_lr-swanstation() {
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
        -DCMAKE_CXX_FLAGS="${CXXFLAGS} -Wno-enum-constexpr-conversion" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/swanstation_libretro.so"
}

function install_lr-swanstation() {
    md_ret_files=('build/swanstation_libretro.so')
}

function configure_lr-swanstation() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "psx"
        mkUserDir "${biosdir}/psx"
        defaultRAConfig "psx"

        isPlatform "rpi2" && setRetroArchCoreOption "swanstation_GPU.Renderer" "Software"
    fi

    addEmulator 0 "${md_id}" "psx" "${md_inst}/swanstation_libretro.so" 

    addSystem "psx"
}
