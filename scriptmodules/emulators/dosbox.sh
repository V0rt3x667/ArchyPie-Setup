#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dosbox"
rp_module_desc="DOSBox - MS-DOS Emulator"
rp_module_help="ROM Extensions: .bat .com .exe .sh .conf\n\nCopy your DOS games to $romdir/pc"
rp_module_licence="GPL2 https://sourceforge.net/p/dosbox/code-0/HEAD/tree/dosbox/trunk/COPYING"
rp_module_repo="svn https://svn.code.sf.net/p/dosbox/code-0/dosbox/trunk - 4465"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_dosbox() {
    local depends=(
        'alsa-lib'
        'alsa-utils'
        'libpng'
        'zlib'
        "$@"
    )
    [[ "$md_id" == "dosbox" ]] && depends+=('sdl' 'sdl_net' 'sdl_sound')
    isPlatform "rpi" && depends+=('timidity++')
    getDepends "${depends[@]}"
}

function sources_dosbox() {
    local revision="$1"
    [[ -z "$revision" ]] && revision="4465"

    svn checkout "$md_repo_url" "$md_build" -r "$revision"
}

function build_dosbox() {
    local params=()

    ! isPlatform "x11" && params+=(--disable-opengl)
    # add or override params from calling function
    params+=("$@")

    ./autogen.sh
    ./configure --prefix="$md_inst" "${params[@]}"
    if isPlatform "arm"; then
        # enable dynamic recompilation for armv4
        sed -i 's|/\* #undef C_DYNREC \*/|#define C_DYNREC 1|' config.h
        sed -i 's/C_TARGETCPU.*/C_TARGETCPU ARMV7LE/g' config.h
        sed -i 's|/\* #undef C_UNALIGNED_MEMORY \*/|#define C_UNALIGNED_MEMORY 1|' config.h
    fi
    make clean
    make
    md_ret_require="$md_build/src/dosbox"
}

function install_dosbox() {
    make install
    md_ret_require="$md_inst/bin/dosbox"
}

function configure_dosbox() {
    local def=0
    local launcher_name="+Start DOSBox.sh"
    local needs_synth=0
    local config_dir="$home/.$md_id"
    case "$md_id" in
        dosbox-sdl2)
            launcher_name="+Start DOSBox-SDL2.sh"
            ;;
        dosbox)
            def=1
            # needs software synth for midi; limit to Pi for now
            isPlatform "rpi" && needs_synth=1
            ;;
        dosbox-staging)
            launcher_name="+Start DOSBox-Staging.sh"
            config_dir="$home/.config/dosbox"
            ;;
        dosbox-x)
            launcher_name="+Start DOSBox-X.sh"
            config_dir="$home/.config/dosbox-x"
            ;;
        *)
            return 1
            ;;
    esac

    mkRomDir "pc"

    moveConfigDir "$config_dir" "$md_conf_root/pc"

    addEmulator "$def" "$md_id" "pc" "bash $romdir/pc/${launcher_name// /\\ } %ROM%"
    addSystem "pc"

    rm -f "$romdir/pc/$launcher_name"
    [[ "$md_mode" == "remove" ]] && return

    cat > "$romdir/pc/$launcher_name" << _EOF_
#!/bin/bash

[[ ! -n "\$(aconnect -o | grep -e TiMidity -e FluidSynth)" ]] && needs_synth="$needs_synth"

function midi_synth() {
    [[ "\$needs_synth" != "1" ]] && return

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
    params=(-c "@MOUNT C $romdir/pc -freesize 1024" -c "@C:")
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

# fullscreen when running in X
[[ -n "\$DISPLAY" ]] && params+=(-fullscreen)

midi_synth start
if [[ "$md_id" == "dosbox-x" ]]; then
    "$md_inst/bin/dosbox-x" "\${params[@]}"
else
    "$md_inst/bin/dosbox" "\${params[@]}"
fi
midi_synth stop
_EOF_
    chmod +x "$romdir/pc/$launcher_name"
    chown "${user}:${user}" "$romdir/pc/$launcher_name"

    if [[ "$md_id" == "dosbox" || "$md_id" == "dosbox-sdl2" ]]; then
        local config_path=$(su "${user}" -c "\"$md_inst/bin/dosbox\" -printconf")
        if [[ -f "$config_path" ]]; then
            iniConfig " = " "" "$config_path"
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
}
