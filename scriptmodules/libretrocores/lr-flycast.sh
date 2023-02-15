#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-flycast"
rp_module_desc="Sega Dreamcast, Naomi, Naomi 2 & Atomiswave Libretro Core"
rp_module_help="ROM Extensions: .7z .bin .cdi .chd .cue .dat .elf .gdi .lst .m3u .zip\n\nCopy Dreamcast & Naomi ROMs To: ${romdir}/dreamcast\n\nCopy Dreamcast BIOS Files (dc_boot.bin & dc_flash.bin) To: ${biosdir}/dreamcast/dc\n\nCopy Naomi & Atomiswave BIOS Files (awbios.zip & naomi.zip) To: ${biosdir}/dreamcast/dc/"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/flycast/master/LICENSE"
rp_module_repo="git https://github.com/libretro/flycast master"
rp_module_section="opt"
rp_module_flags=""

function depends_lr-flycast() {
    local depends=('zlib')

    getDepends "${depends[@]}"
}

function sources_lr-flycast() {
    gitPullOrClone

    # Prevent ArchyPie C/CXXFLAGS From Being Overwritten
    sed -e "s|^CFLAGS[[:blank:]]*:=[[:blank:]]*|#CFLAGS :=|g" -i "${md_build}/Makefile"
    sed -e "s|^CXXFLAGS[[:blank:]]*:=[[:blank:]]*|#CXXFLAGS :=|g" -i "${md_build}/Makefile"
    sed -e "s|^OPTFLAGS[[:blank:]]*:=[[:blank:]]*-O3|OPTFLAGS := -O2|g" -i "${md_build}/Makefile"
}

function build_lr-flycast() {
    local params=('HAVE_LTCG=0')

    isPlatform "aarch64" && params+=('WITH_DYNAREC=arm64' 'HOST_CPU_FLAGS=-DTARGET_LINUX_ARMv8')
    isPlatform "arm" && params+=('WITH_DYNAREC=arm')
    ! isPlatform "x86" && params+=('HAVE_GENERIC_JIT=0')
    isPlatform "vulkan" && params+=('HAVE_VULKAN=1') || params+=('HAVE_VULKAN=0')

    make "${params[@]}" clean
    make "${params[@]}"

    md_ret_require="${md_build}/flycast_libretro.so"
}

function install_lr-flycast() {
    md_ret_files=('flycast_libretro.so')
}

function configure_lr-flycast() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "arcade"
        mkRomDir "dreamcast"

        mkUserDir "${biosdir}/dreamcast"
        mkUserDir "${biosdir}/dreamcast/dc"
    fi

    defaultRAConfig "arcade" "system_directory" "${biosdir}/dreamcast"
    defaultRAConfig "dreamcast" "system_directory" "${biosdir}/dreamcast"

    addEmulator 0 "${md_id}" "arcade" "${md_inst}/flycast_libretro.so"
    addEmulator 1 "${md_id}" "dreamcast" "${md_inst}/flycast_libretro.so"

    addSystem "arcade"
    addSystem "dreamcast"
}
