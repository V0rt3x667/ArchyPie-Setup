#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="amiberry"
rp_module_desc="Amiberry: Commodore Amiga Emulator"
rp_module_help="ROM Extension: .adf .chd .ipf .lha .zip\n\nCopy Amiga Games To: ${romdir}/amiga\nCopy CD32 Games To: ${romdir}/amigacd32\nCopy CDTV Games To: ${romdir}/amigacdtv\n\nCopy BIOS Files:\n\nkick34005.A500\nkick40063.A600\nkick40068.A1200\nkick40060.CD32\nkick34005.CDTV\n\nTo: ${biosdir}/amiga"
rp_module_licence="GPL3 https://raw.githubusercontent.com/BlitterStudio/amiberry/master/LICENSE"
rp_module_repo="git https://github.com/BlitterStudio/amiberry :_get_branch_amiberry"
rp_module_section="opt"
rp_module_flags="!all arm rpi2 rpi3 rpi4 rpi5 x86_64"

function _get_branch_amiberry() {
    download "https://api.github.com/repos/BlitterStudio/amiberry/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_amiberry() {
    local depends=(
        'clang'
        'cmake'
        'flac'
        'libmpeg2'
        'libpng'
        'libserialport'
        'libxml2'
        'lld'
        'mpg123'
        'portmidi'
        'sdl2_image'
        'sdl2_ttf'
        'sdl2'
        'wget'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_amiberry() {
    gitPullOrClone

    # Set Fullscreen By Default
    applyPatch "${md_data}/01_set_fullscreen.patch"
}

function build_amiberry() {
    # Build CAPSImg
    cd external/capsimg || exit
    ./bootstrap
    ./configure
    make clean
    make

    # Build Amiberry
    cd "${md_build}" || exit
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
        -Wno-dev
    ninja -C build clean
    ninja -C build

    md_ret_require="${md_build}/build/${md_id}"
}

function install_amiberry() {
    md_ret_files=(
        'build/abr'
        'build/amiberry'
        'build/data'
        'build/kickstarts'
    )

    # Install CapsImg Library
    mkdir "${md_inst}/plugins"
    cp -Pv "${md_build}"/external/capsimg/capsimg.so "${md_inst}/plugins"

    # Install WHDBoot
    cp -R "${md_build}/whdboot" "${md_inst}/whdboot-dist"
}

function configure_amiberry() {
    local systems=(
        'amiga'
        'amigacd32'
        'amigacdtv'
    )

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/amiga/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
        done

        mkUserDir "${biosdir}/amiga"

        # Move Data Folders & Files
        local dirs=(
            'conf'
            'nvram'
            'savestates'
            'screenshots'
        )
        for dir in "${dirs[@]}"; do
            moveConfigDir "${md_inst}/${dir}" "${md_conf_root}/amiga/${md_id}/${dir}"
        done

        moveConfigDir "${md_inst}/kickstarts" "${biosdir}/amiga"
        moveConfigDir "${md_inst}/whdboot" "${md_conf_root}/amiga/${md_id}/whdboot"
        moveConfigFile "${md_inst}/data/cd32.nvr" "${md_conf_root}/amiga/${md_id}/cd32.nvr"

        # Copy Data
        cp -R "${md_inst}"/whdboot-dist/{game-data,save-data,boot-data.zip,WHDLoad} "${md_conf_root}/amiga/${md_id}/whdboot/"

        # Symlink Retroarch Configs For Amiberry To Use
        moveConfigDir "${md_inst}/controllers" "${configdir}/all/retroarch/autoconfig"
        moveConfigFile "${md_inst}/conf/retroarch.cfg" "${configdir}/all/retroarch.cfg"

        # Fix Permissions On BIOS & WHDLoad Directories
        chown -R "${user}:${user}" "${biosdir}/amiga"
        chown -R "${user}:${user}" "${md_conf_root}/amiga/${md_id}/whdboot"

        # Use Shared UAE4ARM/Amiberry Launcher Script While '${md_id}=1'
        sed -e "s|is_${md_id}=0|is_${md_id}=1|g" "${md_data}/../uae4arm/uae4arm.sh" >"${md_inst}/amiberry.sh"
        chmod a+x "${md_inst}/${md_id}.sh"

        # Create EmulationStation Launcher Script
        local launcher="+Start ${md_id}.sh"
        cat > "${romdir}/amiga/${launcher}" << _EOF_
#!/bin/bash
"pushd ${md_inst}; ${md_inst}/${md_id}.sh; popd"
_EOF_
        chmod a+x "${romdir}/amiga/${launcher}"
        chown "${user}:${user}" "${romdir}/amiga/${launcher}"
    fi

    addEmulator 0 "${md_id}-a1200"    "amiga"     "${md_inst}/${md_id}.sh %ROM% --model A1200"
    addEmulator 0 "${md_id}-a4000"    "amiga"     "${md_inst}/${md_id}.sh %ROM% --model A4000"
    addEmulator 0 "${md_id}-a500"     "amiga"     "${md_inst}/${md_id}.sh %ROM% --model A500"
    addEmulator 0 "${md_id}-a500plus" "amiga"     "${md_inst}/${md_id}.sh %ROM% --model A500P"
    addEmulator 1 "${md_id}-cd32"     "amigacd32" "${md_inst}/${md_id}.sh %ROM% --model CD32"
    addEmulator 1 "${md_id}-cdtv"     "amigacdtv" "${md_inst}/${md_id}.sh %ROM% --model CDTV"
    addEmulator 1 "${md_id}"          "amiga"     "${md_inst}/${md_id}.sh %ROM%"

    for system in "${systems[@]}"; do
        addSystem "${system}"
    done
}
