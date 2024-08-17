#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lime3ds"
rp_module_desc="Lime3DS: Nintendo 3DS Emulator"
rp_module_help="ROM Extensions: .3ds .3dsx .app .axf .cci .cia .cxi .elf\n\nCopy Nintendo 3DS ROMs To: ${romdir}/3ds\n\nNOTE: .cia ROMs Will Only Work If An 'aes_keys.txt' File Exists In The '${arpdir}/lime3ds/sysdata' Folder"
rp_module_licence="GPL2 https://raw.githubusercontent.com/Lime3DS/Lime3DS/master/license.txt"
rp_module_repo="git https://github.com/Lime3DS/Lime3DS 2117.1"
rp_module_section="opt"
rp_module_flags="!all x86_64"

function depends_lime3ds() {
    local depends=(
        'boost'
        'catch2'
        'clang'
        'cmake'
        'crypto++'
        'doxygen'
        'enet'
        'faad2'
        'ffmpeg'
        'fmt'
        'glslang'
        'libfdk-aac'
        'libinih'
        'libusb'
        'libxkbcommon'
        'llvm'
        'mbedtls'
        'ninja'
        'nlohmann-json'
        'openal'
        'openssl'
        'qt6-base'
        'qt6-multimedia-ffmpeg'
        'qt6-tools'
        'qt6-wayland'
        'rapidjson'
        'sdl2'
        'sndio'
        'soundtouch'
        'speexdsp'
        'vulkan-headers'
        'zstd'
        'zydis'
    )
    getDepends "${depends[@]}"
}

function sources_lime3ds() {
    gitPullOrClone

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"
}

function build_lime3ds() {
    # Lime3DS Will Not Link With 'lld' Or 'mold' As Of 2117.1
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCITRA_WARNINGS_AS_ERRORS="OFF" \
        -DDISABLE_SYSTEM_CPP_HTTPLIB="ON" \
        -DDISABLE_SYSTEM_CPP_JWT="ON" \
        -DDISABLE_SYSTEM_CUBEB="ON" \
        -DDISABLE_SYSTEM_DYNARMIC="ON" \
        -DDISABLE_SYSTEM_FFMPEG_HEADERS="ON" \
        -DDISABLE_SYSTEM_LODEPNG="ON" \
        -DDISABLE_SYSTEM_VMA="ON" \
        -DDISABLE_SYSTEM_XBYAK="ON" \
        -DENABLE_DEDICATED_ROOM="OFF" \
        -DENABLE_LTO="ON" \
        -DENABLE_QT_TRANSLATION="ON" \
        -DENABLE_TESTS="OFF" \
        -DENABLE_WEB_SERVICE="OFF" \
        -DUSE_SYSTEM_LIBS="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/bin/Release/lime3ds-gui"
}

function install_lime3ds() {
    ninja -C build install/strip
}

function configure_lime3ds() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/3ds/${md_id}"

    [[ "${md_mode}" == "install" ]] && mkRomDir "3ds"

    addEmulator 0 "${md_id}"     "3ds" "${md_inst}/bin/lime3ds-cli -f %ROM%"
    addEmulator 0 "${md_id}-gui" "3ds" "${md_inst}/bin/lime3ds-gui %ROM%"

    addSystem "3ds"
}
