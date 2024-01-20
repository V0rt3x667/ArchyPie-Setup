#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="cgenius"
rp_module_desc="Commander Genius: Modern Interpreter For The Commander Keen Games (Vorticon and Galaxy Games)"
rp_module_licence="GPL2 https://raw.githubusercontent.com/gerstrong/Commander-Genius/master/COPYRIGHT"
rp_module_repo="git https://gitlab.com/Dringgstein/Commander-Genius :_get_branch_cgenius"
rp_module_section="opt"

function _get_branch_cgenius() {
    download "https://gitlab.com/api/v4/projects/Dringgstein%2FCommander-Genius/releases" - | grep -m 1 tag_name | cut -d\" -f8
}

function depends_cgenius() {
    local depends=(
        'clang'
        'cmake'
        'curl'
        'lld'
        'ninja'
        'perl-rename'
        'sdl2_image'
        'sdl2_mixer'
        'sdl2_ttf'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_cgenius() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|/.CommanderGenius|/ArchyPie/configs/${md_id}|g" -i "${md_build}/GsKit/base/interface/FindFile.cpp"
}

function build_cgenius() {
    local params=()
    isPlatform "gl" && params+=(-DUSE_OPENGL="ON")

    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_C_FLAGS="${CFLAGS} -Wno-implicit-function-declaration" \
        -DAPPDIR="${md_inst}/bin" \
        -DSHAREDIR="${md_inst}/share" \
        -DBUILD_COSMOS="ON" \
        -DNOTYPESAVE="ON" \
        -DUSE_BOOST="OFF" \
        "${params[*]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/src/CGeniusExe"
}

function install_cgenius() {
    ninja -C build install/strip
}

function _add_games_cgenius(){
    local cmd="${1}"
    local dir
    local game
    local portname

    declare -A games=(
        ['keen1/keen1.exe']="Keen 1: Marooned on Mars (Invasion of the Vorticons)"
        ['keen2/keen2.exe']="Keen 2: The Earth Explodes (Invasion of the Vorticons)"
        ['keen3/keen3.exe']="Keen 3: Keen Must Die! (Invasion of the Vorticons)"
        ['kdreams/kdreams.exe']="Keen Dreams (Lost Episode)"
        ['keen4/keen4.exe']="Keen 4: Secret of the Oracle (Goodbye, Galaxy!)"
        ['keen4/keen4e.exe']="Keen 4: Secret of the Oracle (Goodbye, Galaxy!)"
        ['keen5/keen5.exe']="Keen 5: The Armageddon Machine (Goodbye, Galaxy!)"
        ['keen5/keen5e.exe']="Keen 5: The Armageddon Machine (Goodbye, Galaxy!)"
        ['keen6/keen6.exe']="Keen 6: Aliens Ate My Baby Sitter! (Goodbye, Galaxy!)"
    )

    for game in "${!games[@]}"; do
        portname="cgenius"
        dir="${romdir}/ports/${portname}/${game%%/*}"
        # Convert Uppercase Filenames To Lowercase
        [[ "${md_mode}" == "install" ]] && changeFileCase "${dir}"
        # Create Launch Scripts For Each Game Found
        if [[ -f "${dir}/${game##*/}" ]]; then
            addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd} dir=games/%ROM%" "${game%%/*}"
        fi
    done
}

function configure_cgenius() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'kdreams'
            'keen1'
            'keen2'
            'keen3'
            'keen4'
            'keen5'
            'keen6'
        )
        mkRomDir "ports/${md_id}"
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${md_id}/${dir}"
        done

        # Symlink 'games' Directory To ${romdir}/ports/cgenius
        moveConfigDir "${arpdir}/${md_id}/games" "${romdir}/ports/${md_id}/"

        # Create Default Configuration File
        local config
        config="$(mktemp)"
        iniConfig " = " "" "${config}"

        echo "[Video]" > "${config}"
        iniSet "fullscreen" "true"
        isPlatform "gl" && iniSet "OpenGL" "true"
        echo "[FileHandling]" >> "${config}"
        iniSet "EnableLogfile" "false"
        iniSet "SearchPath1" "${md_conf_root}/${md_id}"

        copyDefaultConfig "${config}" "${md_conf_root}/${md_id}/${md_id}.cfg"
        rm "${config}"
    fi

    _add_games_cgenius "${md_inst}/bin/CGeniusExe"
}
