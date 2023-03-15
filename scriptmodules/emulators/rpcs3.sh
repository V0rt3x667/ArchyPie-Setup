#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="rpcs3"
rp_module_desc="RPCS3: Sony PlayStation 3 Emulator"
rp_module_help="ROM Extensions: .ps3 .psn\n\nCopy PS3 ROMs To: ${romdir}/ps3\n\nCopy BIOS File (PS3UPDAT.PUP) To: ${biosdir}/ps3\n\nREQUIRED: On First Run Launch +Start rpcs3.sh, This Will Prompt You To Install PS3UPDAT.PUP. DO NOT Launch Games From The RPCS3 GUI!\n\nPut Your Decrypted ps3 Game Files In A Folder Suffixed With .ps3, Your Game Will Then Be Visible In EmulationStation.\n\nSee https://wiki.batocera.org/systems:ps3 For Further Details."
rp_module_licence="GPL2 https://raw.githubusercontent.com/RPCS3/rpcs3/master/LICENSE"
rp_module_repo="git https://github.com/RPCS3/rpcs3 master"
rp_module_section="exp"
rp_module_flags="!all x86_64"

function depends_rpcs3() {
    local depends=(
        'alsa-lib'
        'ccache'
        'clang14'
        'cmake'
        'ffmpeg'
        'flatbuffers'
        'glew'
        'glu'
        'libevdev'
        'libgl'
        'libglvnd'
        'libice'
        'libpng'
        'libpulse'
        'libsm'
        'libx11'
        'libxext'
        'llvm-libs'
        'ninja'
        'openal'
        'pugixml'
        'python'
        'qt5-base'
        'qt5-declarative'
        'sdl2'
        'vulkan-icd-loader'
        'vulkan-validation-layers'
        'wolfssl'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_rpcs3() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|\"%s/.config\"|\"%s/ArchyPie/configs/${md_id}\"|g" -i "${md_build}/3rdparty/libsdl-org/SDL/src/core/linux/SDL_ibus.c"
    sed -e "s|\"/.local/share/\"|\"/ArchyPie/configs/${md_id}/\"|g" -i "${md_build}/3rdparty/libsdl-org/SDL/src/filesystem/unix/SDL_sysfilesystem.c"
    sed -e "s|\"/.config\"|\"/ArchyPie/configs\"|g" -i "${md_build}/Utilities/File.cpp"
}

function build_rpcs3() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="/usr/lib/llvm14/bin/clang" \
        -DCMAKE_CXX_COMPILER="/usr/lib/llvm14/bin/clang++" \
        -DDISABLE_LTO="ON" \
        -DUSE_SYSTEM_CURL="ON" \
        -DUSE_SYSTEM_FFMPEG="ON" \
        -DUSE_SYSTEM_LIBPNG="ON" \
        -DUSE_SYSTEM_PUGIXML="ON" \
        -DUSE_SYSTEM_SDL="ON" \
        -DUSE_SYSTEM_ZLIB="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/bin/${md_id}"
}

function install_rpcs3() {
    ninja -C build install/strip
}

function configure_rpcs3() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/ps3/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ps3"

        mkUserDir "${biosdir}/ps3"

        # Create EmulationStation Launcher Script
        local launcher="+Start ${md_id}.sh"
        cat > "${romdir}/ps3/${launcher}" << _EOF_
#!/bin/bash
${md_inst}/bin/${md_id} --installfw ${biosdir}/ps3/PS3UPDAT.PUP
_EOF_
        chmod a+x "${romdir}/ps3/${launcher}"
        chown "${user}:${user}" "${romdir}/ps3/${launcher}"
    fi

    addEmulator 1 "${md_id}-nogui" "ps3" "${md_inst}/bin/rpcs3 --fullscreen --no-gui %ROM%"

    addSystem "ps3"
}
