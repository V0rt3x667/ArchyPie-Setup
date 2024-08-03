#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="pcsx2"
rp_module_desc="PCSX2: Sony PlayStation 2 Emulator"
rp_module_help="ROM Extensions: .bin .bz2 .chd .cso .dump .gz .ima .img .iso .mdf .z .z2\n\nCopy PS2 ROMs To: ${romdir}/ps2\n\nCopy BIOS Files: ps2-0230a-20080220, ps2-0230e-20080220 & ps2-0230j-20080220 To: ${biosdir}/ps2"
rp_module_licence="GPL3 https://raw.githubusercontent.com/PCSX2/pcsx2/master/COPYING.GPLv3"
rp_module_repo="git https://github.com/PCSX2/pcsx2 master"
rp_module_section="main"
rp_module_flags="!all x86_64 !kms"

function depends_pcsx2() {
    local depends=(
        'clang'
        'cmake'
        'curl'
        'doxygen'
        'extra-cmake-modules'
        'ffmpeg'
        'fmt'
        'glslang'
        'libaio'
        'libglvnd'
        'libpcap'
        'libpng'
        'libwebp'
        'libx11'
        'libxext'
        'libzip'
        'lld'
        'llvm'
        'lz4'
        'ninja'
        'p7zip'
        'png++'
        'portaudio'
        'python'
        'qt6-base'
        'qt6-svg'
        'qt6-tools'
        'qt6-wayland'
        'rapidyaml'
        'sdl2'
        'sndio'
        'soundtouch'
        'spirv-headers'
        'spirv-tools'
        'vulkan-icd-loader'
        'wayland-protocols'
        'wayland'
        'xz'
        'zlib'
        'zstd'
    )
    getDepends "${depends[@]}"
}

function sources_pcsx2() {
    gitPullOrClone

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"

    # Get 'shaderc' PCSX2 Requires A Custom Build, Ref: https://github.com/PCSX2/pcsx2/wiki/10-Building-on-Linux
    gitPullOrClone "${md_build}/shaderc" "https://github.com/google/shaderc" "main"
    applyPatch "${md_data}/02_custom_shaderc.patch"

    # Get Patches & Compress Them
    gitPullOrClone "${md_build}/patches" "https://github.com/PCSX2/pcsx2_patches" "main"
    7z a -r "${md_build}/patches/patches.zip" "${md_build}/patches/patches/."
}

function build_pcsx2() {
    # Build 'shaderc'
    echo "*** Building shaderc ***"
    cd "${md_build}/shaderc" || exit
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_INSTALL_PREFIX="${md_build}/deps" \
        -DCMAKE_LINKER_TYPE="LLD" \
        -Dglslang_SOURCE_DIR="/usr/include/glslang" \
        -DSHADERC_SKIP_COPYRIGHT_CHECK="ON" \
        -DSHADERC_SKIP_EXAMPLES="ON" \
        -DSHADERC_SKIP_TESTS="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build install

    # Build 'pcsx2'
    echo "*** Building PCSX2 ***"
    cd "${md_build}" || exit
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -Wl,-rpath='${md_inst}/lib'" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_LINKER_TYPE="LLD" \
        -DCMAKE_PREFIX_PATH="${md_build}/deps" \
        -DENABLE_TESTS="OFF" \
        -DLTO_PCSX2_CORE="ON" \
        -DUSE_BACKTRACE="OFF" \
        -DUSE_SYSTEM_LIBS="ON" \
        -DWAYLAND_API="ON" \
        -DX11_API="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/bin/${md_id}-qt"
}

function install_pcsx2() {
    md_ret_files=(
        "build/bin/pcsx2-qt"
        "build/bin/resources"
        "build/bin/translations"
    )

    # Install 'shaderc' Library
    mkdir "${md_inst}/lib"
    cp -Pv "${md_build}/deps/lib/libshaderc_shared.so" "${md_inst}/lib"

    # Install Patch Files
    install -Dm644 "${md_build}/patches/patches.zip" -t "${md_inst}/resources"
}

function configure_pcsx2() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/ps2/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ps2"

        mkUserDir "${biosdir}/ps2"
        mkUserDir "${arpdir}/${md_id}/inis"

        # Set Default Config File
        local config
        config="$(mktemp)"
        iniConfig " = " "" "${config}"

        echo "[UI]" > "${config}"
        iniSet "SettingsVersion" "1"
        iniSet "StartFullscreen" "true"
        iniSet "HideMouseCursor" "true"
        iniSet "ConfirmShutdown" "false"
        echo "[GameList]" >> "${config}"
        iniSet "Paths" "${romdir}/ps2"
        echo "[Folders]" >> "${config}"
        iniSet "Bios" "${biosdir}/ps2"

        copyDefaultConfig "${config}" "${md_conf_root}/ps2/${md_id}/inis/PCSX2.ini"
        rm "${config}"
    fi

    addEmulator 1 "${md_id}"     "ps2" "${md_inst}/pcsx2-qt -nogui -fullscreen %ROM%"
    addEmulator 0 "${md_id}-gui" "ps2" "${md_inst}/pcsx2-qt -fullscreen"

    addSystem "ps2"
}
