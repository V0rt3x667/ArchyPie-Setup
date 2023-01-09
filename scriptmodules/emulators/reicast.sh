#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="reicast"
rp_module_desc="Reicast - Sega Dreamcast Emulator"
rp_module_help="ROM Extensions: .cdi .chd .gdi\n\nCopy your Dreamcast roms to $romdir/dreamcast\n\nCopy the required BIOS files dc_boot.bin and dc_flash.bin to $biosdir/dc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/reicast/reicast-emulator/master/LICENSE"
rp_module_repo="git https://github.com/reicast/reicast-emulator.git master"
rp_module_section="opt"
rp_module_flags=""

function depends_reicast() {
    local depends=(sdl2 python python-evdev alsa-oss python-setuptools libevdev libpulse libao alsa-lib systemd)
    isPlatform "mesa" && depends+=(libglvnd)
    getDepends "${depends[@]}"
}

function sources_reicast() {
    gitPullOrClone
    applyPatch "$md_data/0001-enable-rpi4-sdl2-target.patch"
    applyPatch "$md_data/0002-enable-vsync.patch"
    applyPatch "$md_data/0003-fix-sdl2-sighandler-conflict.patch"
}

function _params_reicast() {
    local platform
    local subplatform
    local params=()

    # platform-specific params
    if isPlatform "rpi" && isPlatform "32bit"; then
        # platform configuration
        if isPlatform "rpi4"; then
            platform="rpi4"
        elif isPlatform "rpi3"; then
            platform="rpi3"
        else
            platform="rpi2"
        fi

        # subplatform configuration
        if isPlatform "rpi4"; then
            # we need to target SDL with GLES3 disabled for KMSDRM compatibility
            subplatform="-sdl"
        elif isPlatform "mesa"; then
            subplatform="-mesa"
        fi

        params+=("platform=${platform}${subplatform}")
    else
        # generic flags
        isPlatform "x11" && params+=("USE_X11=1")
        isPlatform "kms" || isPlatform "gles" && params+=("USE_GLES=1")
        isPlatform "kms" && params+=("USE_X11=" "HAS_SOFTREND=" "USE_SDL=1")
    fi

    echo "${params[*]}"
}

function build_reicast() {
    cd shell/linux
    make $(_params_reicast) clean
    make $(_params_reicast)

    md_ret_require="$md_build/shell/linux/reicast.elf"
}

function install_reicast() {
    cd shell/linux
    make $(_params_reicast) PREFIX="$md_inst" install

    md_ret_files=(
        'LICENSE'
        'README.md'
    )
}

function configure_reicast() {
    local backend
    local backends=(alsa omx oss)
    local params=("%ROM%")

    # KMS reqires Xorg context & X/Y res passed.
    if isPlatform "kms"; then
        params+=("%XRES%" "%YRES%")
    fi

    # copy hotkey remapping start script
    cp "$md_data/reicast.sh" "$md_inst/bin/"
    chmod +x "$md_inst/bin/reicast.sh"

    mkRomDir "dreamcast"

    # move any old configs to the new location
    moveConfigDir "$home/.reicast" "$md_conf_root/dreamcast/"

    # Create home VMU, cfg, and data folders. Copy dc_boot.bin and dc_flash.bin to the ~/.reicast/data/ folder.
    mkdir -p "$md_conf_root/dreamcast/"{data,mappings}

    # symlink bios
    mkUserDir "$biosdir/dc"
    ln -sf "$biosdir/dc/"{dc_boot.bin,dc_flash.bin} "$md_conf_root/dreamcast/data"

    # copy default mappings
    cp "$md_inst/share/reicast/mappings/"*.cfg "$md_conf_root/dreamcast/mappings/"

    chown -R "${user}:${user}" "$md_conf_root/dreamcast"

    if [[ "$md_mode" == "install" ]]; then
        cat > "$romdir/dreamcast/+Start Reicast.sh" << _EOF_
#!/bin/bash
$md_inst/bin/reicast.sh
_EOF_
        chmod a+x "$romdir/dreamcast/+Start Reicast.sh"
        chown "${user}:${user}" "$romdir/dreamcast/+Start Reicast.sh"
    else
        rm "$romdir/dreamcast/+Start Reicast.sh"
    fi

    if [[ "$md_mode" == "install" ]]; then
        # possible audio backends: alsa, oss, omx
        if isPlatform "rpi"; then
            backends=(omx oss)
        else
            backends=(alsa)
        fi
    fi

    # add system(s)
    for backend in "${backends[@]}"; do
        addEmulator 1 "${md_id}-audio-${backend}" "dreamcast" "$md_inst/bin/reicast.sh $backend ${params[*]}"
    done
    addSystem "dreamcast"

    addAutoConf reicast_input 1
}

function input_reicast() {
    local temp_file="$(mktemp)"
    cd "$md_inst/bin"
    ./reicast-joyconfig -f "$temp_file" >/dev/tty
    iniConfig " = " "" "$temp_file"
    iniGet "mapping_name"
    local mapping_file="$configdir/dreamcast/mappings/evdev_${ini_value//[:><?\"]/-}.cfg"
    mv "$temp_file" "$mapping_file"
    chown "${user}:${user}" "$mapping_file"
}

function gui_reicast() {
    while true; do
        local options=(
            1 "Configure input devices for Reicast"
        )
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "${choice}" ]] && break
        case "${choice}" in
            1)
                clear
                input_reicast
                ;;
        esac
    done
}
