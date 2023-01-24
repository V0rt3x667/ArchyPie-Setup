#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="uae4arm"
rp_module_desc="UAE4ARM: Commodore Amiga Emulator"
rp_module_help="ROM Extension: .adf .ipf\n\nCopy Amiga Games To: ${romdir}/amiga\n\nCopy BIOS Files\n\nkick13.rom\nkick20.rom\nkick31.rom\n\nTo: ${biosdir}/amiga"
rp_module_licence="GPL2"
rp_module_repo="git https://github.com/Chips-fr/uae4arm-rpi master"
rp_module_section="opt"
rp_module_flags="!all rpi"

function depends_uae4arm() {
    local depends=(
        'flac'
        'guichan'
        'libmpeg2'
        'libmpg123'
        'libpng'
        'libxml2'
        'sdl_gfx'
        'sdl_image'
        'sdl_mixer'
        'sdl_ttf'
        'sdl12-compat'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_uae4arm() {
    gitPullOrClone
}

function build_uae4arm() {
    make clean
    make CXXFLAGS=""

    md_ret_require="${md_build}/${md_id}"
}

function install_uae4arm() {
    md_ret_files=(
        'data'
        'uae4arm'
    )
}

function configure_uae4arm() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/amiga/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "amiga"

        mkUserDir "${biosdir}/amiga"

        # Symlink Configuration, Savestates & Screenshots Directories
        local dirs=(
            'conf'
            'savestates'
            'screenshots'
        )
        for dir in "${dirs[@]}"; do
            moveConfigDir "${md_inst}/${dir}" "${md_conf_root}/amiga/${md_id}/${dir}"
        done

        # Symlink BIOS Directory
        moveConfigDir "${md_inst}/kickstarts" "${biosdir}/amiga"

        # Set Default A500 Configuration File
        local conf
        conf="$(mktemp)"
        iniConfig "=" "" "${conf}"

        iniSet "config_description" "ArchyPie A500, 68000, OCS, 512KB Chip + 512KB Slow Fast"
        iniSet "chipmem_size" "1"
        iniSet "bogomem_size" "2"
        iniSet "chipset" "ocs"
        iniSet "cachesize" "0"
        iniSet "kickstart_rom_file" "\$(FILE_PATH)/kick13.rom"

        copyDefaultConfig "${conf}" "${md_conf_conf}/amiga/${md_id}/conf/rp-a500.uae"
        rm "${conf}"

        # Set Default A1200 Configuration File
        conf="$(mktemp)"
        iniConfig "=" "" "${conf}"

        iniSet "config_description" "ArchyPie A1200, 68EC020, AGA, 2MB Chip"
        iniSet "chipmem_size" "4"
        iniSet "finegrain_cpu_speed" "1024"
        iniSet "cpu_type" "68ec020"
        iniSet "cpu_model" "68020"
        iniSet "chipset" "aga"
        iniSet "cachesize" "0"
        iniSet "kickstart_rom_file" "\$(FILE_PATH)/kick31.rom"

        copyDefaultConfig "${conf}" "${md_conf_conf}/amiga/${md_id}/conf/rp-a1200.uae"
        rm "${conf}"

        # Use Shared UAE4ARM/Amiberry Launcher Script
        cp "${md_data}/${md_id}.sh" "${md_inst}/"
        chmod a+x "${md_inst}/${md_id}.sh"

        # Create EmulationStation Launcher Script
        local launcher="+Start UAE4Arm.sh"
        cat > "${romdir}/amiga/${launcher}" << _EOF_
#!/bin/bash
"${md_inst}/${md_id}.sh"
_EOF_
        chmod a+x "${romdir}/amiga/${launcher}"
        chown "${user}:${user}" "${romdir}/amiga/${script}"
    fi

    addEmulator 1 "${md_id}" "amiga" "${md_inst}/${md_id}.sh %ROM%"
    addEmulator 0 "${md_id}-a500" "amiga" "${md_inst}/${md_id}.sh %ROM% -config=conf/rp-a500.uae"
    addEmulator 0 "${md_id}-a1200" "amiga" "${md_inst}/${md_id}.sh %ROM% -config=conf/rp-a1200.uae"

    addSystem "amiga"
}
