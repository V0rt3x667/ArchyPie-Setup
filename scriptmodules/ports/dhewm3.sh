#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dhewm3"
rp_module_desc="dhewm3 - DOOM 3 Port"
rp_module_licence="GPL3 https://raw.githubusercontent.com/dhewm/dhewm3/master/COPYING.txt"
rp_module_repo="git https://github.com/dhewm/dhewm3.git :_get_branch_dhewm3"
rp_module_section="opt"
rp_module_flags="!all 64bit"

function _get_branch_dhewm3() {
    download https://api.github.com/repos/dhewm/dhewm3/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_dhewm3() {
    local depends=(
        'cmake'
        'curl'
        'libjpeg'
        'libvorbis'
        'ninja'
        'openal'
        'perl-rename'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_dhewm3() {
    gitPullOrClone

    applyPatch "$md_data/01_set_default_config_path.patch"
}

function build_dhewm3() {
    cmake . \
        -Sneo \
        -GNinja \
        -Bbuild \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -Wl,-rpath='$md_inst/lib'" \
        -DREPRODUCIBLE_BUILD=1 \
        -DD3XP=1 \
        -DDEDICATED=1 \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/dhewm3"
}

function install_dhewm3() {
    ninja -C build install/strip
}

function _game_data_dhewm3() {
    local url
    url="https://files.holarse-linuxgaming.de/native/Spiele/Doom%203/Demo/doom3-linux-1.1.1286-demo.x86.run"
    if [[ ! -f "$romdir/ports/doom3/base/pak000.pk4" ]] || [[ ! -f "$romdir/ports/doom3/demo/demo00.pk4" ]]; then
        download "$url" "$romdir/ports/doom3"
        chmod +x "$romdir/ports/doom3/doom3-linux-1.1.1286-demo.x86.run"
        cd "$romdir/ports/doom3" || return
        ./doom3-linux-1.1.1286-demo.x86.run --tar xf demo/ && rm "$romdir/ports/doom3/doom3-linux-1.1.1286-demo.x86.run"
        chown "$user:$user" "$romdir/ports/doom3/demo"
    fi
}

function _add_games_dhewm3() {
    local cmd="$1"
    local dir
    local game
    declare -A games=(
        ['base/pak000.pk4']="Doom III"
        ['demo/demo00.pk4']="Doom III (Demo)"
        ['d3xp/pak000.pk4']="Doom III: Resurrection of Evil"
    )

    # Create .sh files for each game found. Uppercase filenames will be converted to lowercase.
    for game in "${!games[@]}"; do
        dir="$romdir/ports/doom3"
        pushd "$dir/${game%%/*}"
        perl-rename 'y/A-Z/a-z/' [^.-]*
        popd
        if [[ -f "$dir/$game" ]]; then
            addPort "$md_id" "doom3" "${games[$game]}" "$cmd" "${game%%/*}"
        fi
    done
}

function configure_dhewm3() {
    moveConfigDir "$arpiedir/ports/$md_id" "$md_conf_root/doom3/$md_id"

    if [[ "$md_mode" == "install" ]]; then
        mkRomDir "ports/doom3"

        mkUserDir "$arpiedir/ports"
        mkUserDir "$arpiedir/ports/$md_id"

        _game_data_dhewm3
    fi

    local basedir="$romdir/ports/doom3"
    _add_games_dhewm3 "$md_inst/bin/dhewm3 +set fs_basepath $basedir +set r_fullscreen 1 +set fs_game %ROM%"
}
