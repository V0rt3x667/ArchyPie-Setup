#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

rp_module_id="lr-play"
rp_module_desc="Sony PlayStation 2 Libretro Core"
rp_module_help="ROM Extensions: .chd .cso .cue .elf .iso .isz\n\nCopy PS2 ROMs To: ${romdir}/ps2"
rp_module_licence="MIT https://raw.githubusercontent.com/jpd002/Play-/master/License.txt"
rp_module_repo="git https://github.com/jpd002/Play- master"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function depends_lr-play() {
    local depends=(
        'bzip2'
        'glang'
        'glew'
        'glibc'
        'icu'
        'libgl'
        'libglvnd'
        'lld'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_lr-play() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|\".local/share\"|\"ArchyPie/configs\"|g" -i "${md_build}/deps/Framework/src/PathUtils.cpp"
    sed -e "s|\"Play Data Files\"|\"${md_id}\"|g" -i "${md_build}/Source/AppConfig.cpp"
}

function build_lr-play() {
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
        -DBUILD_LIBRETRO_CORE="ON" \
        -DBUILD_PLAY="OFF" \
        -DBUILD_TESTS="OFF" \
        -DENABLE_AMAZON_S3="OFF" \
        -DWITH_SYSTEM_ZLIB="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/Source/ui_libretro/play_libretro.so"
}

function install_lr-play() {
    md_ret_files=(
        'build/Source/ui_libretro/play_libretro.so'
        'License.txt'
    )
}

function configure_lr-play() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/ps2/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ps2"
        defaultRAConfig "ps2"
    fi

    addEmulator 0 "${md_id}" "ps2" "${md_inst}/play_libretro.so"

    addSystem "ps2"
}
