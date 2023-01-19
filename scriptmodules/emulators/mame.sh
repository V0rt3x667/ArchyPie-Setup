#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="mame"
rp_module_desc="MAME: Arcade Machine & Computer Emulator (Latest Version)"
rp_module_help="ROM Extensions: .7z .zip\n\nCopy MAME ROMs To Either: ${romdir}/mame\n\n${romdir}/arcade"
rp_module_licence="GPL2 https://raw.githubusercontent.com/mamedev/mame/master/COPYING"
rp_module_repo="git https://github.com/mamedev/mame :_get_branch_mame"
rp_module_section="main"
rp_module_flags=""

function _get_branch_mame() {
    download "https://api.github.com/repos/mamedev/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_mame() {
    local depends=(
        'flac'
        'glm'
        'libpulse'
        'libutf8proc'
        'libx11'
        'lua53'
        'nasm'
        'portaudio'
        'portmidi'
        'pugixml'
        'python'
        'qt5-base'
        'rapidjson'
        'sdl2_ttf'
        'sdl2'
    )
    isPlatform "x11" && params+=('libxinerama')
    getDepends "${depends[@]}"
}

function sources_mame() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|# SDL_INI_PATH = .;\$HOME/.mame/;ini;|SDL_INI_PATH = \$HOME/ArchyPie/configs/${md_id}/;|g" -i "${md_build}/makefile"

    # Use System Libraries
    sed -e "s|\# USE_SYSTEM_LIB|USE_SYSTEM_LIB|g" -i "${md_build}/makefile"

    # Except for ASIO
    sed -e "s|USE_SYSTEM_LIB_ASIO|\# USE_SYSTEM_LIB_ASIO|g" -i "${md_build}/makefile"
}

function build_mame() {
    # More Memory Is Required For 64bit Platforms
    if isPlatform "64bit"; then
        rpSwap on 8192
    else
        rpSwap on 4096
    fi

    export CFLAGS+=" -I/usr/include/lua5.3/"
    export CXXFLAGS+=" -I/usr/include/lua5.3/"

    # Force Linking To lua5.3
    mkdir lib
    ln -s /usr/lib/liblua5.3.so lib/liblua.so
    export LDFLAGS+=" -L${PWD}/lib"

    local params=(
        'LTO=0'
        'NOWERROR=1'
        'OPTIMIZE=2'
        'PYTHON_EXECUTABLE=python'
    )
    # ! isPlatform "x11" && params+=('NO_X11=1') Breaks Linking
    # Error: '/usr/bin/ld: /usr/lib/libX11.so.6: error adding symbols: DSO missing from command line'

    make clean
    make "${params[@]}"

    rpSwap off

    md_ret_require="${md_build}/${md_id}"
}

function install_mame() {
    md_ret_files=(
        'artwork'
        'bgfx'
        'COPYING'
        'ctrlr'
        'docs'
        'hash'
        'hlsl'
        'ini'
        'language'
        'mame'
        'plugins'
        'roms'
        'samples'
        'uismall.bdf'
    )
}

function configure_mame() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "arcade"
        mkRomDir "${md_id}"

        # Create BIOS Directory
        mkUserDir "${biosdir}/${md_id}"

        # Create MAME Directories
        local dirs=(
            'artwork'
            'cfg'
            'comments'
            'diff'
            'inp'
            'nvram'
            'samples'
            'scores'
            'snap'
            'sta'
        )
        for dir in "${dirs[@]}"; do
            mkRomDir "${md_id}/${dir}"
        done

        # Create MAME Config File
        local config
        config="$(mktemp)"

        iniConfig " " "" "${config}"
        iniSet "artpath"            "${romdir}/${md_id}/artwork;${romdir}/arcade/artwork"
        iniSet "ctrlrpath"          "${md_inst}/ctrlr"
        iniSet "hashpath"           "${md_inst}/hash"
        iniSet "languagepath"       "${md_inst}/language"
        iniSet "pluginspath"        "${md_inst}/plugins"
        iniSet "rompath"            "${romdir}/${md_id};${romdir}/arcade;${biosdir}/${md_id}"
        iniSet "samplepath"         "${romdir}/${md_id}/samples;${romdir}/arcade/samples"

        iniSet "cfg_directory"      "${romdir}/${md_id}/cfg"
        iniSet "comment_directory"  "${romdir}/${md_id}/comments"
        iniSet "diff_directory"     "${romdir}/${md_id}/diff"
        iniSet "input_directory"    "${romdir}/${md_id}/inp"
        iniSet "nvram_directory"    "${romdir}/${md_id}/nvram"
        iniSet "snapshot_directory" "${romdir}/${md_id}/snap"
        iniSet "state_directory"    "${romdir}/${md_id}/sta"

        iniSet "plugin" "hiscore"
        iniSet "samplerate" "44100"
        iniSet "skip_gameinfo" "1"

        # Raspberry Pis Show Improved Performance Using Accelerated Mode Which Enables 'SDL_RENDERER_TARGETTEXTURE'
        iniSet "video" "accel"

        copyDefaultConfig "${config}" "${md_conf_root}/${md_id}/mame.ini"
        rm "${config}"

        # Create MAME UI Config File
        local config_ui
        config_ui="$(mktemp)"
        iniConfig " " "" "${config_ui}"
        iniSet "scores_directory" "${romdir}/${md_id}/scores"
        copyDefaultConfig "${config_ui}" "${md_conf_root}/${md_id}/ui.ini"
        rm "${config_ui}"

        # Create MAME Plugin Config File
        local config_plugin
        config_plugin="$(mktemp)"
        iniConfig " " "" "${config_plugin}"
        iniSet "hiscore" "1"
        copyDefaultConfig "${config_plugin}" "${md_conf_root}/${md_id}/plugin.ini"
        rm "${config_plugin}"

        # Create MAME Hi Score Config File
        local config_hiscore
        config_hiscore="$(mktemp)"
        iniConfig " " "" "${config_hiscore}"
        iniSet "hi_path" "${romdir}/${md_id}/scores"
        copyDefaultConfig "${config_hiscore}" "${md_conf_root}/${md_id}/hiscore.ini"
        rm "${config_hiscore}"
    fi

    local params=()
    isPlatform "wayland" && params+=('-videodriver wayland' '-video opengl')

    addEmulator 0 "${md_id}" "arcade" "${md_inst}/mame ${params[*]} %BASENAME%"
    addEmulator 1 "${md_id}" "${md_id}" "${md_inst}/mame ${params[*]} %BASENAME%"

    addSystem "arcade"
    addSystem "${md_id}"
}
