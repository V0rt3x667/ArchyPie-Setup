#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dosbox"
rp_module_desc="DOSBox: MS-DOS Emulator"
rp_module_help="ROM Extensions: .bat .com .conf .exe .sh\n\nCopy DOS Games To: ${romdir}/pc"
rp_module_licence="GPL2 https://sourceforge.net/p/dosbox/code-0/HEAD/tree/dosbox/trunk/COPYING"
rp_module_repo="svn https://svn.code.sf.net/p/dosbox/code-0/dosbox/trunk"
rp_module_section="opt"
rp_module_flags=""

function depends_dosbox() {
    local depends=(
        'alsa-lib'
        'alsa-utils'
        'libpng'
        'sdl_net'
        'sdl_sound'
        'sdl12-compat'
        'subversion'
        'zlib'
    )
    isPlatform "rpi" && depends+=('timidity++')
    getDepends "${depends[@]}"
}

function sources_dosbox() {
    svn checkout "${md_repo_url}" "${md_build}"

    # Set Default Config Path(s)
    sed -e "s|in = \"~/.dosbox\";|in = \"~/ArchyPie/configs/${md_id}\";|g" -i "${md_build}/src/misc/cross.cpp"
}

function build_dosbox() {
    local params=()

    ! isPlatform "x11" && params+=('--disable-opengl')

    ./autogen.sh
    ./configure --prefix="${md_inst}" "${params[@]}"
    make clean
    make
    md_ret_require=("${md_build}/src/${md_id}")
}

function install_dosbox() {
    make install
    md_ret_require=("${md_inst}/bin/${md_id}")
}

function configure_dosbox() {
    if [[ "${md_mode}" == "install" ]]; then
        local def=0
        local launcher_name="+Start DOSBox.sh"
        local needs_synth=0
        local config_dir="${arpdir}/${md_id}"
        case "${md_id}" in
            dosbox)
                def=1
                # Use Software Synth For MIDI
                isPlatform "rpi" && needs_synth=1
                ;;
            dosbox-staging)
                launcher_name="+Start DOSBox-Staging.sh"
                ;;
            dosbox-x)
                launcher_name="+Start DOSBox-X.sh"
                ;;
            *)
                return 1
                ;;
        esac

        mkRomDir "pc"

        cat > "${romdir}/pc/${launcher_name}" << _EOF_
#!/bin/bash

[[ ! -n "\$(aconnect -o | grep -e TiMidity -e FluidSynth)" ]] && needs_synth="${needs_synth}"

function midi_synth() {
    [[ "\${needs_synth}" != "1" ]] && return

    case "\$1" in
        "start")
            timidity -Os -iAD &
            i=0
            until [[ -n "\$(aconnect -o | grep TiMidity)" || "\$i" -ge 10 ]]; do
                sleep 1
                ((i++))
            done
            ;;
        "stop")
            killall timidity
            ;;
        *)
            ;;
    esac
}

params=("\$@")
if [[ -z "\${params[0]}" ]]; then
    params=(-c "@MOUNT C ${romdir}/pc -freesize 1024" -c "@C:")
elif [[ "\${params[0]}" == *.sh ]]; then
    midi_synth start
    bash "\${params[@]}"
    midi_synth stop
    exit
elif [[ "\${params[0]}" == *.conf ]]; then
    params=(-userconf -conf "\${params[@]}")
else
    params+=(-exit)
fi

midi_synth start
if [[ "${md_id}" == "dosbox-x" ]]; then
    "${md_inst}/bin/dosbox-x" -fullscreen "\${params[@]}"
else
    "${md_inst}/bin/dosbox" -fullscreen "\${params[@]}"
fi
midi_synth stop
_EOF_
        chmod +x "${romdir}/pc/${launcher_name}"
        chown "${user}:${user}" "${romdir}/pc/${launcher_name}"

        if [[ "${md_id}" == "dosbox" ]]; then
            local config_path
            config_path=$(su "${user}" -c "\"${md_inst}/bin/dosbox\" -printconf")
            if [[ -f "${config_path}" ]]; then
                iniConfig " = " "" "${config_path}"
                iniSet "usescancodes" "false"
                iniSet "core" "dynamic"
                iniSet "cycles" "max"
                iniSet "scaler" "none"
                if isPlatform "rpi" || [[ -n "$(aconnect -o | grep -e TiMidity -e FluidSynth)" ]]; then
                    iniSet "mididevice" "alsa"
                    iniSet "midiconfig" "128:0"
                fi
            fi
        fi
    fi

    moveConfigDir "${config_dir}" "${md_conf_root}/pc"

    addEmulator "${def}" "${md_id}" "pc" "bash ${romdir}/pc/${launcher_name// /\\ } %ROM%"

    addSystem "pc"
}
