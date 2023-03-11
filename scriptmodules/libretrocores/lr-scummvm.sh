#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-scummvm"
rp_module_desc="ScummVM Libretro Core"
rp_module_help="Copy ScummVM Games To: ${romdir}/scummvm\n\nGame Directories Must Be Suffixed With '.svm' For Direct Launch In EmulationStation"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/scummvm/main/LICENSE"
rp_module_repo="git https://github.com/libretro/scummvm main"
rp_module_section="exp"

function depends_lr-scummvm() {
    local depends=('zip')
    getDepends "${depends[@]}"
}

function sources_lr-scummvm() {
    gitPullOrClone
}

function build_lr-scummvm() {
    make clean
    make USE_MT32EMU=1
    make datafiles
    md_ret_require="${md_build}/scummvm_libretro.so"
}

function install_lr-scummvm() {
    md_ret_files=(
        "scummvm_libretro.so"
        "scummvm.zip"
    )
}

function configure_lr-scummvm() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "scummvm"

        defaultRAConfig "scummvm" "system_directory" "${biosdir}/scummvm"

        # Unpack Data Files To System Directory
        runCmd unzip -q -o "${md_inst}/scummvm.zip" -d "${biosdir}"
        chown -R "${user}:${user}" "${biosdir}/scummvm"

        # Create Default Configuration File
        local config
        config="$(mktemp)"
        iniConfig " = " "" "${config}"
        
        echo "[scummvm]" > "${config}"
        iniSet "extrapath" "${biosdir}/scummvm/extra"
        iniSet "themepath" "${biosdir}/scummvm/theme"
        iniSet "soundfont" "${biosdir}/scummvm/extra/Roland_SC-55.sf2"
        iniSet "gui_theme" "scummremastered"
        iniSet "subtitles" "true"
        iniSet "multi_midi" "true"
        iniSet "gm_device" "fluidsynth"

        copyDefaultConfig "${config}" "${biosdir}/scummvm/scummvm.ini"
        rm "${config}"

        # Enable Speed Hack Core Option For ARM Platform
        isPlatform "arm" && setRetroArchCoreOption "scummvm_speed_hack" "enabled"

        # Create RetroArch Launcher For 'lr-scummvm'
        cat > "${md_inst}/romdir-launcher.sh" << _EOF_
#!/usr/bin/env bash
ROM=\$1; shift
SVM_FILES=()
[[ -d \${ROM} ]] && mapfile -t SVM_FILES < <(compgen -G "\${ROM}/*.svm")
[[ \${#SVM_FILES[@]} -eq 1 ]] && ROM=\${SVM_FILES[0]}
${emudir}/retroarch/bin/retroarch \\
    -L "${md_inst}/scummvm_libretro.so" \\
    --config "${md_conf_root}/scummvm/retroarch.cfg" \\
    "\${ROM}" "\$@"
_EOF_
        chmod +x "${md_inst}/romdir-launcher.sh"
    fi

    addEmulator 0 "${md_id}" "scummvm" "${md_inst}/romdir-launcher.sh %ROM%"

    addSystem "scummvm"
}
