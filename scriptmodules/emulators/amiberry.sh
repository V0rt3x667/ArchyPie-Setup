#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="amiberry"
rp_module_desc="Amiberry: Commodore Amiga Emulator"
rp_module_help="ROM Extension: .adf .chd .ipf .lha .zip\n\nCopy Amiga Games To: ${romdir}/amiga\n\nCopy BIOS Files:\n\nkick13.rom\nkick20.rom\nkick31.rom\n\nTo: ${biosdir}/amiga"
rp_module_licence="GPL3 https://raw.githubusercontent.com/BlitterStudio/amiberry/master/LICENSE"
rp_module_repo="git https://github.com/BlitterStudio/amiberry :_get_branch_amiberry"
rp_module_section="opt"
rp_module_flags="!all arm x86_64"

function _get_branch_amiberry() {
    download "https://api.github.com/repos/BlitterStudio/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function _get_platform_amiberry() {
    local platform="${__platform}-sdl2"
    if isPlatform "aarch64" && isPlatform "rpi"; then
        platform="${__platform}-64-sdl2"
    elif isPlatform "odroid-xu"; then
        platform="xu4"
    elif isPlatform "odroid-c1"; then
        platform="c1"
    elif isPlatform "x86" && isPlatform "64bit"; then
        platform="x86-64"
    fi
    echo "${platform}"
}

function depends_amiberry() {
    local depends=(
        'flac'
        'libmpeg2'
        'libpng'
        'libxml2'
        'mpg123'
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

    applyPatch "${md_data}/01_preserve_env.patch"
}

function build_amiberry() {
    local platform
    platform="$(_get_platform_amiberry)"

    cd external/capsimg || exit
    ./bootstrap
    ./configure
    make clean
    make

    cd "${md_build}" || exit
    make clean
    make PLATFORM="${platform}" CPUFLAGS="${__cpu_flags}"
    md_ret_require="${md_build}/${md_id}"
}

function install_amiberry() {
    md_ret_files=(
        'abr'
        'amiberry'
        'data'
        'external/capsimg/capsimg.so'
        'kickstarts'
    )
    cp -R "${md_build}/whdboot" "${md_inst}/whdboot-dist"
}

function configure_amiberry() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/amiga/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "amiga"
        mkUserDir "${biosdir}/amiga"

        # Move Data Folders & Files
        local dir
        for dir in conf nvram savestates screenshots; do
            moveConfigDir "${md_inst}/${dir}" "${md_conf_root}/amiga/${md_id}/${dir}"
        done
        moveConfigDir "${md_inst}/kickstarts" "${biosdir}/amiga"
        moveConfigDir "${md_inst}/whdboot" "${md_conf_root}/amiga/${md_id}/whdboot"
        moveConfigFile "${md_inst}/data/cd32.nvr" "${md_conf_root}/amiga/${md_id}/cd32.nvr"

        # Copy Data
        cp -R "${md_inst}"/whdboot-dist/{game-data,save-data,boot-data.zip,WHDLoad} "${md_conf_root}/amiga/${md_id}/whdboot/"

        # Symlink Retroarch Configs For Amiberry To Use
        ln -sf "${configdir}/all/retroarch/autoconfig" "${md_inst}/controllers"
        ln -sf "${configdir}/all/retroarch.cfg" "${md_inst}/conf/retroarch.cfg"

        # Fix Permissions on BIOS & WHDLoad Directories
        chown -R "${user}:${user}" "${biosdir}/amiga"
        chown -R "${user}:${user}" "${md_conf_root}/amiga/${md_id}/whdboot"

        # Use Shared UAE4ARM/Amiberry Launcher Script While '${md_id}=1'
        sed -e "s|is_${md_id}=0|is_${md_id}=1|g" "${md_data}/../uae4arm/uae4arm.sh" >"${md_inst}/amiberry.sh"
        chmod a+x "${md_inst}/${md_id}.sh"

        local script="+Start ${md_id}.sh"
        cat > "${romdir}/amiga/${script}" << _EOF_
#!/bin/bash
"${md_inst}/${md_id}.sh"
_EOF_
        chmod a+x "${romdir}/amiga/${script}"
        chown "${user}:${user}" "${romdir}/amiga/${script}"
    fi

    addEmulator 0 "${md_id}-a1200" "amiga" "${md_inst}/${md_id}.sh %ROM% --model A1200"
    addEmulator 0 "${md_id}-a4000" "amiga" "${md_inst}/${md_id}.sh %ROM% --model A4000"
    addEmulator 0 "${md_id}-a500" "amiga" "${md_inst}/${md_id}.sh %ROM% --model A500"
    addEmulator 0 "${md_id}-a500plus" "amiga" "${md_inst}/${md_id}.sh %ROM% --model A500P"
    addEmulator 1 "${md_id}-cd32" "cd32" "${md_inst}/${md_id}.sh %ROM% --model CD32"
    addEmulator 1 "${md_id}-cdtv" "cdtv" "${md_inst}/${md_id}.sh %ROM% --model CDTV"
    addEmulator 1 "${md_id}" "amiga" "${md_inst}/${md_id}.sh %ROM%"

    addSystem "amiga"
    addSystem "cd32"
    addSystem "cdtv"
}
