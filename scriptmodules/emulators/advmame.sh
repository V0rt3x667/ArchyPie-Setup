#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="advmame"
rp_module_desc="AdvanceMAME: Arcade Machine Emulator (MAME 0.106)"
rp_module_help="ROM Extension: .zip\n\nCopy AdvanceMAME ROMs to: $romdir/mame-advmame or $romdir/arcade"
rp_module_licence="GPL2 https://raw.githubusercontent.com/amadvance/advancemame/master/COPYING"
rp_module_repo="git https://github.com/amadvance/advancemame master"
rp_module_section="opt"
rp_module_flags=""

function depends_advmame() {
    local depends=('sdl2')
    if isPlatform "videocore"; then
        depends+=('raspberrypi-firmware')
    fi
    getDepends "${depends[@]}"
}

function sources_advmame() {
    gitPullOrClone
    applyPatch "$md_data/01_set_default_config_path.patch"
}

function build_advmame() {
    local params=('--enable-sdl2' '--disable-sdl' '--disable-oss')
    if isPlatform "videocore"; then
        params+=('--enable-vc')
    else
        params+=('--disable-vc')
    fi

    ./autogen.sh
    ./configure CFLAGS="$CFLAGS -fno-stack-protector" --prefix="$md_inst" "${params[@]}"
    make clean
    make
    md_ret_require="$md_build/$md_id"
}

function install_advmame() {
    make install
}

function configure_advmame() {
    if [[ "$md_mode" == "install" ]]; then
        mkRomDir "arcade"
        mkRomDir "arcade/$md_id"
        mkRomDir "mame-$md_id"

        local dirs=(
            'artwork'
            'diff'
            'hi'
            'inp'
            'memcard'
            'nvram'
            'sample'
            'snap'
            'sta'
        )
        for dir in "${dirs[@]}"; do
            mkRomDir "mame-$md_id/$dir"
            ln -sf "$romdir/mame-$md_id/$dir" "$romdir/arcade/$md_id"
        done

        mkUserDir "$arpdir/$md_id"
        moveConfigDir "$arpdir/$md_id" "$md_conf_root/mame-$md_id"
    fi

    if [[ "$md_mode" == "install" && ! -f "$md_conf_root/mame-$md_id/$md_id.rc" ]]; then
        su "$user" -c "$md_inst/bin/$md_id --default"

        iniConfig " " "" "$md_conf_root/mame-$md_id/$md_id.rc"

        iniSet "misc_quiet" "yes"
        iniSet "dir_rom" "$romdir/mame-$md_id:$romdir/arcade"
        iniSet "dir_artwork" "$romdir/mame-$md_id/artwork"
        iniSet "dir_sample" "$romdir/mame-$md_id/samples"
        iniSet "dir_diff" "$romdir/mame-$md_id/diff"
        iniSet "dir_hi" "$romdir/mame-$md_id/hi"
        iniSet "dir_image" "$romdir/mame-$md_id"
        iniSet "dir_inp" "$romdir/mame-$md_id/inp"
        iniSet "dir_memcard" "$romdir/mame-$md_id/memcard"
        iniSet "dir_nvram" "$romdir/mame-$md_id/nvram"
        iniSet "dir_snap" "$romdir/mame-$md_id/snap"
        iniSet "dir_sta" "$romdir/mame-$md_id/nvram"

        if isPlatform "videocore"; then
            iniSet "device_video" "fb"
            iniSet "device_video_cursor" "off"
            iniSet "device_keyboard" "raw"
            iniSet "device_sound" "alsa"
            iniSet "display_vsync" "no"
            iniSet "sound_normalize" "no"
            iniSet "display_resizeeffect" "none"
            iniSet "display_resize" "integer"
            iniSet "display_magnify" "1"
        else
            iniSet "device_video" "sdl"
            # Need to force keyboard device as auto will choose event driver which doesn't work with sdl
            iniSet "device_keyboard" "sdl"
            # Default for best performance
            iniSet "display_magnify" "1"
            # Disable threading to get rid of the crash-on-exit when using SDL, preventing config save
            iniSet "misc_smp" "no"
            iniSet "device_video_output" "overlay"
            iniSet "display_aspectx" 16
            iniSet "display_aspecty" 9
            iniSet "sound_samplerate" "44100"
        fi
    fi

    addEmulator 1 "$md_id" "arcade" "$md_inst/bin/$md_id %BASENAME%"
    addEmulator 1 "$md_id" "mame-$md_id" "$md_inst/bin/$md_id %BASENAME%"

    addSystem "arcade"
    addSystem "mame-$md_id"
}
