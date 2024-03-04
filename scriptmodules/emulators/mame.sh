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
    download "https://api.github.com/repos/mamedev/mame/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_mame() {
    local depends=(
        'asio'
        'bzip2'
        'clang'
        'expat'
        'flac'
        'glm'
        'harfbuzz'
        'libjpeg-turbo'
        'libpng'
        'libpulse'
        'libutf8proc'
        'lld'
        'lua'
        'nasm'
        'portaudio'
        'portmidi'
        'pugixml'
        'python'
        'rapidjson'
        'sdl2_ttf'
        'sdl2'
        'sqlite'
        'zlib'
        'zstd'
    )
    isPlatform "x11" && params+=(
        'libx11'
        'libxi'
        'libxinerama'
    )
    getDepends "${depends[@]}"
}

function sources_mame() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|# SDL_INI_PATH = .;\$HOME/.mame/;ini;|SDL_INI_PATH = ~/ArchyPie/configs/${md_id}/|g" -i "${md_build}/makefile"

    # Use System Libraries
    sed -e "s|\# USE_SYSTEM_LIB|USE_SYSTEM_LIB|g" -i "${md_build}/makefile"

    # Use C++ LUA
    sed -e "s|ext_lib(\"lua\")|ext_lib(\"lua++\")|g" -i "${md_build}/scripts/src/main.lua" -i "${md_build}/scripts/src/3rdparty.lua"
}

function build_mame() {
    if isPlatform "64bit"; then
        rpSwap on 10240
    else
        rpSwap on 8192
    fi

    local params=(
        'LTO=0'
        'NOWERROR=1'
        'OVERRIDE_CC=clang'
        'OVERRIDE_CXX=clang++'
        'PYTHON_EXECUTABLE=python'
        'STRIP_SYMBOLS=1'
        'SYMBOLS=0'
        'USE_QTDEBUG=0'
    )
    isPlatform "kms" && params+=('NO_X11=1')
    isPlatform "x11" && params+=('USE_WAYLAND=1')

    make clean
    LDFLAGS+=" -fuse-ld=lld" make "${params[@]}"

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
        iniSet "homepath"           "${md_conf_root}/${md_id}"
        iniSet "rompath"            "${romdir}/${md_id};${romdir}/arcade;${biosdir}/${md_id}"
        iniSet "hashpath"           "${md_inst}/hash"
        iniSet "samplepath"         "${romdir}/${md_id}/samples;${romdir}/arcade/samples"
        iniSet "artpath"            "${romdir}/${md_id}/artwork;${romdir}/arcade/artwork"
        iniSet "ctrlrpath"          "${md_inst}/ctrlr"
        iniSet "pluginspath"        "${md_inst}/plugins"
        iniSet "languagepath"       "${md_inst}/language"

        iniSet "cfg_directory"      "${romdir}/${md_id}/cfg"
        iniSet "nvram_directory"    "${romdir}/${md_id}/nvram"
        iniSet "input_directory"    "${romdir}/${md_id}/inp"
        iniSet "state_directory"    "${romdir}/${md_id}/sta"
        iniSet "snapshot_directory" "${romdir}/${md_id}/snap"
        iniSet "diff_directory"     "${romdir}/${md_id}/diff"
        iniSet "comment_directory"  "${romdir}/${md_id}/comments"

        iniSet "skip_gameinfo" "1"
        iniSet "plugin" "hiscore"
        iniSet "samplerate" "44100"

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
    addEmulator 0 "${md_id}" "arcade" "${md_inst}/mame ${params[*]} %BASENAME%"
    addEmulator 1 "${md_id}" "${md_id}" "${md_inst}/mame ${params[*]} %BASENAME%"

    addSystem "arcade"
    addSystem "${md_id}"
}
