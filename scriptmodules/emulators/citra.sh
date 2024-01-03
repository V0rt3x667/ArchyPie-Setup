#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="citra"
rp_module_desc="Citra: Nintendo 3DS Emulator"
rp_module_help="ROM Extensions: .3ds .3dsx .app .axf .cci .cia .cxi .elf\n\nCopy Nintendo 3DS ROMs To: ${romdir}/3ds\n\nNOTE: .cia ROMs Will Only Work If An 'aes_keys.txt' File Exists In The '${arpdir}/citra/sysdata' Folder"
rp_module_licence="GPL2 https://raw.githubusercontent.com/citra-emu/citra/master/license.txt"
rp_module_repo="git https://github.com/citra-emu/citra master"
rp_module_section="main"
rp_module_flags="!all 64bit vulkan"

function depends_citra() {
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
        #'glslang'
        'libfdk-aac'
        'libinih'
        'libusb'
        'libxkbcommon'
        'lld'
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
    )
    getDepends "${depends[@]}"
}

function sources_citra() {
    gitPullOrClone

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"

}

function build_citra() {
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
        -DCITRA_ENABLE_COMPATIBILITY_REPORTING="ON" \
        -DUSE_SYSTEM_LIBS="ON" \
        -DDISABLE_SYSTEM_CPP_HTTPLIB="ON" \
        -DDISABLE_SYSTEM_CPP_JWT="ON" \
        -DDISABLE_SYSTEM_CUBEB="ON" \
        -DDISABLE_SYSTEM_DYNARMIC="ON" \
        -DDISABLE_SYSTEM_GLSLANG="ON" \
        -DDISABLE_SYSTEM_LODEPNG="ON" \
        -DDISABLE_SYSTEM_VMA="ON" \
        -DDISABLE_SYSTEM_XBYAK="ON" \
        -DENABLE_COMPATIBILITY_LIST_DOWNLOAD="ON" \
        -DENABLE_LTO="ON" \
        -DENABLE_QT_TRANSLATION="ON" \
        -DENABLE_TESTS="OFF" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/bin/Release/${md_id}"
}

function install_citra() {
    ninja -C build install/strip
}

function configure_citra() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/3ds/${md_id}"

    [[ "${md_mode}" == "install" ]] && mkRomDir "3ds"

    addEmulator 1 "${md_id}" "3ds" "${md_inst}/bin/${md_id} -f %ROM%"
    addEmulator 0 "${md_id}-gui" "3ds" "${md_inst}/bin/${md_id}-qt %ROM%"

    addSystem "3ds"
}
