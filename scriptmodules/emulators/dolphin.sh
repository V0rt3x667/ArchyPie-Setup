#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dolphin"
rp_module_desc="Dolphin: Nintendo Gamecube & Wii Emulator"
rp_module_help="ROM Extensions: .gcm .iso .wbfs .ciso .gcz .rvz .wad .wbfs\n\nCopy Gamecube ROMs To: ${romdir}/gc\n\nCopy Wii ROMs To: ${romdir}/wii\n\nOPTIONAL: Copy BIOS File: IPL.bin To: ${biosdir}/gc/EUR, ${biosdir}/gc/JAP & ${biosdir}/gc/USA"
rp_module_licence="GPL2 https://raw.githubusercontent.com/dolphin-emu/dolphin/master/COPYING"
rp_module_repo="git https://github.com/dolphin-emu/dolphin master"
rp_module_section="exp"
rp_module_flags="!all x11 64bit"

function depends_dolphin() {
    local depends=(
        'alsa-lib'
        'bluez-libs'
        'bzip2'
        'cmake'
        'curl'
        'ffmpeg'
        'fmt'
        'hidapi'
        'libspng'
        'libx11'
        'libxkbcommon'
        'libxml2'
        'lzo'
        'mbedtls2'
        'miniupnpc'
        'minizip-ng'
        'ninja'
        'pugixml'
        'qt6-base'
        'qt6-svg'
        'sdl2'
        'sfml'
        'soundtouch'
        'speexdsp'
        'xxhash'
        'zstd'
    )
    getDepends "${depends[@]}"
}

function sources_dolphin() {
    gitPullOrClone

    applyPatch "${md_data}/01_set_default_config_path.patch"

    # Fix MiniZip Name
    sed -e "s|MINIZIP minizip>=3.0.0|MINIZIP minizip-ng>=3.0.0|g" -i "${md_build}/CMakeLists.txt"
}

function build_dolphin() {
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
        -DENABLE_ANALYTICS="OFF" \
        -DENABLE_AUTOUPDATE="OFF" \
        -DENABLE_LTO="ON" \
        -DENABLE_QT="ON" \
        -DENABLE_SDL="ON" \
        -DENABLE_TESTS="OFF" \
        -DUSE_SYSTEM_LIBS="ON" \
        -DUSE_SYSTEM_ENET="OFF" \
        -DUSE_SYSTEM_LIBMGBA="OFF" \
        -DUSE_SYSTEM_ZLIB="OFF" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/Binaries/${md_id}-emu"
}

function install_dolphin() {
    ninja -C build install/strip
}

function configure_dolphin() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/gc/${md_id}"

    local systems=(
        'gc'
        'wii'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
        done

        # Create BIOS Directories & Symlink To Dolphin Config Folder
        local dirs=(
            'EUR'
            'JAP'
            'USA'
        )
        mkUserDir "${biosdir}/gba" # For GameCube/GBA Emulated System Link
        mkUserDir "${biosdir}/gc"
        for dir in "${dirs[@]}"; do
            mkUserDir "${biosdir}/gc/${dir}"
        done
        ln -snf "${biosdir}/gc" "${md_conf_root}/gc/${md_id}/GC"

        # Create Default Configuration File
        mkUserDir "${arpdir}/${md_id}/Config"

        local config
        config="$(mktemp)"

        iniConfig " = " "" "${config}"

        # Set Fullscreen By Default
        echo "[Display]" > "${config}"
        iniSet "FullscreenResolution" "Auto"
        iniSet "Fullscreen" "True"
        # Set ROM Paths For GUI
        echo "[General]" >> "${config}"
        iniSet "ISOPath0" "${romdir}/gc"
        iniSet "ISOPath1" "${romdir}/wii"
        iniSet "ISOPaths" "2"
        # Set BIOS File For GameCube/GBA Emulated System Link
        echo "[GBA]" >> "${config}"
        iniSet "BIOS" "${biosdir}/gba/gba_bios.bin"

        copyDefaultConfig "${config}" "${arpdir}/${md_id}/Config/Dolphin.ini"
        rm "${config}"
    fi

    for system in "${systems[@]}"; do
        addEmulator 1 "${md_id}" "${system}" "${md_inst}/bin/${md_id}-emu-nogui -e %ROM%"
        addEmulator 0 "${md_id}-gui" "${system}" "${md_inst}/bin/${md_id}-emu -b -e %ROM%"
        addSystem "${system}"
    done
}
