#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="cemu"
rp_module_desc="Cemu: Nintendo Wii U Emulator"
rp_module_help="ROM Extensions: .wua .wud .wux\n\nCopy Wii U ROMs To: ${romdir}/wiiu\n\nAdd Decryption Keys To: ${home}/ArchyPie/configs/cemu/keys.txt"
rp_module_licence="MPL2 https://raw.githubusercontent.com/cemu-project/Cemu/main/LICENSE.txt"
rp_module_repo="git https://github.com/cemu-project/Cemu main"
rp_module_section="exp"
rp_module_flags="!all x86_64"

function depends_cemu() {
    local depends=(
        'boost-libs'
        'boost'
        'clang'
        'cmake'
        'curl'
        'doxygen'
        'fmt'
        'glm'
        'glslang'
        'glu'
        'libglvnd'
        'libpng'
        'libpulse'
        'libusb'
        'libx11'
        'libzip'
        'lld'
        'llvm-libs'
        'nasm'
        'ninja'
        'openssl'
        'pugixml'
        'rapidjson'
        'sdl2'
        'vulkan-headers'
        'wayland-protocols'
        'wayland'
        'wxwidgets-gtk3'
        'zarchive'
        'zlib'
        'zstd'
    )
    getDepends "${depends[@]}"
}

function sources_cemu() {
    gitPullOrClone

    # Fix 'glslang' & 'cubeb'
    applyPatch "${md_data}/01_fix_glslang_cubeb_errors.patch"

    # Use System 'fmt'
    sed "/FMT_HEADER_ONLY/d" -i "${md_build}/src/Common/precompiled.h"

    # Fix 'glm'
    sed -e "s|glm::glm|glm|g" -i "${md_build}/src/Common/CMakeLists.txt" "${md_build}/src/input/CMakeLists.txt"

    # Set Default Config Path(s)
    sed -e "s|wxS(\"/.local/share\")) + \"/\" + appName|wxS(\"/ArchyPie/configs/${md_id}\"))|g" -i "${md_build}/src/gui/CemuApp.cpp"
    sed -e "s|wxS(\"/.config\")) + \"/\" + appName|wxS(\"/ArchyPie/configs/${md_id}\"))|g" -i "${md_build}/src/gui/CemuApp.cpp"
}

function build_cemu() {
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
        -DENABLE_VCPKG="OFF" \
        -DPORTABLE="OFF" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/bin/Cemu_release"
}

function install_cemu() {
    md_ret_files=(
        'bin/Cemu_release'
        'bin/gameProfiles'
        'bin/shaderCache'
        'bin/resources'
    )
}

function configure_cemu() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/wiiu/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "wiiu"
    fi

    addEmulator 1 "${md_id}" "wiiu" "${md_inst}/Cemu_release -f -g %ROM%"

    addSystem "wiiu"
}
