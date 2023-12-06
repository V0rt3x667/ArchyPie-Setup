#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-dolphin"
rp_module_desc="Nintendo Gamecube & Wii Libretro Core"
rp_module_help="ROM Extensions: .ciso .dff .dol .elf .gcm .gcz .iso .m3u .rvz .tgc .wad .wbfs .wia\n\nCopy Gamecube ROMs To: ${romdir}/gc\n\nCopy Wii ROMs To: ${romdir}/wii\n\nOPTIONAL: Copy BIOS File: IPL.bin To: ${biosdir}/gc/EUR, ${biosdir}/gc/JAP & ${biosdir}/gc/USA"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/dolphin/master/license.txt"
rp_module_repo="git https://github.com/libretro/dolphin master"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function depends_lr-dolphin() {
    depends_dolphin
}

function sources_lr-dolphin() {
    gitPullOrClone

    # Use 'minizip-ng'
    sed -e "s|minizip>=2.0.0|minizip-ng>=2.0.0|g" -i "${md_build}/CMakeLists.txt"

    # Use Bundled 'fmt' Build Fails With System Library
    sed -e "s|find_package(fmt 6.0)|#find_package(fmt 6.0)|g" -i "${md_build}/CMakeLists.txt"

    # Use Bundled 'mbedtls' Build Fails With System Library
    sed -e "s|find_package(MbedTLS)|#find_package(MbedTLS)|g" -i "${md_build}/CMakeLists.txt"
}

function build_lr-dolphin() {
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
        -DENABLE_LTO="ON" \
        -DENABLE_NOGUI="OFF" \
        -DENABLE_QT="OFF" \
        -DENABLE_TESTS="OFF" \
        -DLIBRETRO="ON" \
        -DUSE_DISCORD_PRESENCE="OFF" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/dolphin_libretro.so"
}

function install_lr-dolphin() {
    md_ret_files=(
        'build/dolphin_libretro.so'
        'Data/Sys'
    )
}

function configure_lr-dolphin() {
    local systems=(
        'gc'
        'wii'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            mkUserDir "${biosdir}/${system}"
            defaultRAConfig "${system}"
        done

        # Copy 'Sys' Directory
        mkUserDir "${biosdir}/gc/dolphin-emu"
        cp -r "${md_inst}/Sys" "${biosdir}/gc/dolphin-emu/Sys"
        chown -R "${user}:${user}" "${biosdir}/gc/dolphin-emu/Sys"

        # Symlink 'dolphin-emu' To 'wii' BIOS Folder
        ln -snf "${biosdir}/gc/dolphin-emu" "${biosdir}/wii/dolphin-emu"
    fi

    for system in "${systems[@]}"; do
        addEmulator 1 "${md_id}" "${system}" "${md_inst}/dolphin_libretro.so"
        addSystem "${system}"
    done
}
