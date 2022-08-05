#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="devilutionx"
rp_module_desc="DevilutionX - Diablo & Hellfire Port"
rp_module_licence="TU https://raw.githubusercontent.com/diasurgical/devilutionX/master/LICENSE"
rp_module_repo="git https://github.com/diasurgical/devilutionX.git :_get_branch_devilutionx"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_devilutionx() {
    download https://api.github.com/repos/diasurgical/devilutionX/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_devilutionx() {
    local depends=(
        'cmake'
        'fmt'
        'gettext'
        'libpng'
        'libsodium'
        'ninja'
        'perl-rename'
        'sdl2'
        'sdl2_mixer'
        'sdl2_ttf'
    )
    getDepends "${depends[@]}"
}

function sources_devilutionx() {
    gitPullOrClone
}

function build_devilutionx() {
    local ver 
    ver=$(_get_branch_devilutionx)
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DVERSION_NUM="$ver" \
        -DDEVILUTIONX_SYSTEM_LIBFMT=ON \
        -DDEVILUTIONX_SYSTEM_LIBSODIUM=ON \
        -DBUILD_TESTING=OFF \
        -DPIE=ON \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/devilutionx"
}

function install_devilutionx() {
    md_ret_files=(
        'build/devilutionx'
        'Packaging/resources/assets/'
        'Packaging/nix/README.txt'
    )
}

function _add_games_devilutionx() {
    local cmd="$1"
    local dir
    local game
    declare -A games=(
        ['diabdat.mpq']="Diablo"
        ['hellfire.mpq']="Diablo: Hellfire"
        ['spawn.mpq']="Diablo: Spawn (Shareware)"
    )

    # Create .sh files for each game found. Uppercase filenames will be converted to lowercase.
    for game in "${!games[@]}"; do
        dir="$romdir/ports/diablo"
        pushd "$dir"
        perl-rename 'y/A-Z/a-z/' [^.-]*
        popd
        if [[ -f "$dir/$game" ]]; then
            if [[ "$game" == "diabdat.mpq" ]]; then
                addPort "$md_id" "diablo" "${games[$game]}" "$cmd --%ROM%" "diablo"
            elif [[ "$game" == "hellfire.mpq" ]]; then
                addPort "$md_id" "diablo" "${games[$game]}" "$cmd --%ROM%" "hellfire"
            else
                addPort "$md_id" "diablo" "${games[$game]}" "$cmd --%ROM%" "spawn"
            fi
        fi
    done
}

function configure_devilutionx() {
    mkRomDir "ports/diablo"

    mkUserDir "$arpiedir/ports"
    mkUserDir "$arpiedir/ports/$md_id"

    if [[ "$md_mode" == "install" ]]; then
        moveConfigDir "$arpiedir/ports/$md_id" "$md_conf_root/diablo/$md_id"

        local params=(
            "--config-dir $arpiedir/ports/$md_id"
            "--save-dir $romdir/ports/diablo"
            "--data-dir $md_inst/ports/devilutionx/assets"
        )
        _add_games_devilutionx "$md_inst/devilutionx ${params[*]}"
    fi
}
