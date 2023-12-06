#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-fbneo"
rp_module_desc="FinalBurn Neo Arcade Libretro Core"
rp_module_help="ROM Extension: .7z .zip\n\nCopy FBA ROMs To One Of The Following Directories:\n${romdir}/arcade\n${romdir}/fba\n\nTo Keep Console & Computer ROMs Separate Use The Directories Created For Them Under:\n${romdir}/\n\nCopy FBA BIOS Files To: ${biosdir}/fba"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/FBNeo/master/src/license.txt"
rp_module_repo="git https://github.com/libretro/FBNeo master"
rp_module_section="main"

function sources_lr-fbneo() {
    gitPullOrClone

    # Set BIOS Directory To 'fba'
    sed -e "s|%s%cfbneo|%s%cfba|g" -i "${md_build}/src/burner/libretro/libretro.cpp"
}

function build_lr-fbneo() {
    local params=()
    isPlatform "arm" && params+=('USE_CYCLONE=1')
    isPlatform "neon" && params+=('HAVE_NEON=1')
    isPlatform "x86" && isPlatform "64bit" && params+=('USE_X64_DRC=1')

    make -C src/burner/libretro clean
    make -C src/burner/libretro "${params[@]}"

    md_ret_require="${md_build}/src/burner/libretro/fbneo_libretro.so"
}

function install_lr-fbneo() {
    md_ret_files=(
        'dats'
        'fbahelpfilesrc/fbneo.chm'
        'gamelist.txt'
        'metadata'
        'src/burner/libretro/fbneo_libretro.so'
        'whatsnew.html'
    )
}

function configure_lr-fbneo() {
    local systems=(
        "arcade"
        "channelf"
        "coleco"
        "fba"
        "fds"
        "gamegear"
        "mastersystem"
        "megadrive"
        "msx"
        "neocd"
        "neogeo"
        "nes"
        "ngp"
        "ngpc"
        "pcengine"
        "sg-1000"
        "zxspectrum"
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            defaultRAConfig "${system}"
            mkUserDir "${biosdir}/${system}"
        done

        # Create Directories For Support Files
        local dirs=(
            'blend'
            'cheats'
            'patched'
            'samples'
        )
        for dir in "${dirs[@]}"; do
            mkUserDir "${biosdir}/fba/${dir}"
        done

        # Copy 'hiscore.dat'
        cp "${md_inst}/metadata/hiscore.dat" "${biosdir}/fba"
        chown -R "${user}:${user}" "${biosdir}/fba"

        # Symlink Supported Systems BIOS Dirs To 'fba'
        for system in "${systems[@]}"; do
            if [[ "${system}" != "fba" ]]; then
                ln -snf "${biosdir}/fba" "${biosdir}/${system}/fba"
            fi
        done

        setRetroArchCoreOption "fbneo-diagnostic-input" "Hold Start"

        # OPTIONAL: Force AES System For The NeoGeo Platform
        #local config="${md_conf_root}/neogeo/retroarch-core-options.cfg"
        #iniConfig " = " '"' "${config}"
        #iniSet "fbneo-neogeo-mode" "AES_EUR"
        #chown "${user}:${user}" "${config}"

        # OPTIONAL: Add AES Overide To 'retroarch.cfg', 'defaultRAConfig' Can Only Be Called Once
        #local raconfig="${md_conf_root}/neogeo/retroarch.cfg"
        #iniConfig " = " '"' "${raconfig}"
        #iniSet "core_options_path" "${config}"
        #chown "${user}:${user}" "${raconfig}"
    fi

    addEmulator 0 "${md_id}" "arcade" "${md_inst}/fbneo_libretro.so"
    addEmulator 1 "${md_id}" "fba"    "${md_inst}/fbneo_libretro.so"
    addEmulator 1 "${md_id}" "neogeo" "${md_inst}/fbneo_libretro.so"

    addEmulator 0 "${md_id}-chf"   "channelf"     "${md_inst}/fbneo_libretro.so --subsystem chf"
    addEmulator 0 "${md_id}-cv"    "coleco"       "${md_inst}/fbneo_libretro.so --subsystem cv"
    addEmulator 0 "${md_id}-fds"   "fds"          "${md_inst}/fbneo_libretro.so --subsystem fds"
    addEmulator 0 "${md_id}-gg"    "gamegear"     "${md_inst}/fbneo_libretro.so --subsystem gg"
    addEmulator 0 "${md_id}-md"    "megadrive"    "${md_inst}/fbneo_libretro.so --subsystem md"
    addEmulator 0 "${md_id}-msx"   "msx"          "${md_inst}/fbneo_libretro.so --subsystem msx"
    addEmulator 0 "${md_id}-neocd" "neocd"        "${md_inst}/fbneo_libretro.so --subsystem neocd"
    addEmulator 0 "${md_id}-nes"   "nes"          "${md_inst}/fbneo_libretro.so --subsystem nes"
    addEmulator 0 "${md_id}-ngp"   "ngp"          "${md_inst}/fbneo_libretro.so --subsystem ngp"
    addEmulator 0 "${md_id}-ngpc"  "ngpc"         "${md_inst}/fbneo_libretro.so --subsystem ngp"
    addEmulator 0 "${md_id}-pce"   "pcengine"     "${md_inst}/fbneo_libretro.so --subsystem pce"
    addEmulator 0 "${md_id}-sg1k"  "sg-1000"      "${md_inst}/fbneo_libretro.so --subsystem sg1k"
    addEmulator 0 "${md_id}-sgx"   "pcengine"     "${md_inst}/fbneo_libretro.so --subsystem sgx"
    addEmulator 0 "${md_id}-sms"   "mastersystem" "${md_inst}/fbneo_libretro.so --subsystem sms"
    addEmulator 0 "${md_id}-spec"  "zxspectrum"   "${md_inst}/fbneo_libretro.so --subsystem spec"
    addEmulator 0 "${md_id}-tg"    "pcengine"     "${md_inst}/fbneo_libretro.so --subsystem tg"

    for system in "${systems[@]}"; do
        addSystem "${system}"
    done
}
