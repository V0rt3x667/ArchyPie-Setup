#!/usr/bin/bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

rp_module_id="raze"
rp_module_desc="Raze - Build Engine Port"
rp_module_help="ROM Extensions: .grp\n\nCopy Game Files To:\n$romdir/ports/blood\n$romdir/ports/duke3d\n$romdir/ports/exhumed\n$romdir/ports/nam\n$romdir/ports/redneck\n$romdir/ports/shadow\n$romdir/ports/ww2gi"
rp_module_licence="NONCOM: https://raw.githubusercontent.com/coelckers/Raze/master/build-doc/buildlic.txt"
rp_module_repo="git https://github.com/coelckers/raze.git :_get_branch_raze"
rp_module_section="opt"
rp_module_flags="!all x86 64bit"

function _get_branch_raze() {
    download https://api.github.com/repos/coelckers/raze/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_raze() {
    local depends=(
        'alsa-lib'
        'cmake'
        'fluidsynth'
        'gtk3'
        'libjpeg-turbo'
        'ninja'
        'perl-rename'
        'openal'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_raze() {
    gitPullOrClone
    applyPatch "$md_data/01_fix_file_paths.patch"
    _sources_zmusic
}

function build_raze() {
    _build_zmusic
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -Wl,-rpath='$md_inst/lib'" \
        -DINSTALL_PK3_PATH="$md_inst" \
        -DDYN_GTK=OFF \
        -DDYN_OPENAL=OFF \
        -DZMUSIC_INCLUDE_DIR="$md_build/zmusic/include" \
        -DZMUSIC_LIBRARIES="$md_build/zmusic/source/libzmusic.so" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/raze"
}

function install_raze() {
    md_ret_files=(
        'build/raze.pk3'
        'build/raze'
        'package/common/buildlic.txt'
        'package/common/gamecontrollerdb.txt'
        'package/common/gpl-2.0.txt'
        'soundfont/raze.sf2'
    )
    mkdir "$md_inst/lib"
    cp -Pv "$md_build"/zmusic/source/*.so* "$md_inst/lib"
}

function _add_games_raze() {
    local cmd="$1"
    local dir
    local game
    declare -A games=(
        ['blood/blood.rff']="Blood"
        ['blood/cryptic.ini']="Blood: Cryptic Passage"
        ['duke3d/duke3d.grp']="Duke Nukem 3D"
        ['duke3d/dukedc.grp']="Duke Nukem 3D: Duke It Out in D.C."
        ['duke3d/vacation.grp']="Duke Nukem 3D: Duke Caribbean: Life's a Beach"
        ['duke3d/nwinter.grp']="Duke Nukem 3D: Duke: Nuclear Winter"
        ['exhumed/stuff.dat']="Exhumed (AKA PowerSlave)"
        ['nam/nam.grp']="NAM (AKA Napalm)"
        ['nam/napalm.grp']="Napalm (AKA NAM)"
        ['redneck/redneck.grp']="Redneck Rampage"
        ['redneck/game66.con']="Redneck Rampage: Suckin' Grits on Route 66"
        ['redneckrides/redneck.grp']="Redneck Rampage II: Redneck Rampage Rides Again"
        ['shadow/sw.grp']="Shadow Warrior"
        ['shadow/td.grp']="Shadow Warrior: Twin Dragon"
        ['shadow/wt.grp']="Shadow Warrior: Wanton Destruction"
        ['ww2gi/ww2gi.grp']="World War II GI"
        ['ww2gi/platoonl.dat']="World War II GI: Platoon Leader"
    )

    for game in "${!games[@]}"; do
        dir="$romdir/ports/$game"
        # Convert Uppercase Filenames to Lowercase
        pushd "${dir%/*}"
        perl-rename 'y/A-Z/a-z/' [^.-]*
        popd
        if [[ -f "$dir" ]]; then
            # Add Blood: Cryptic Passage
            if [[ "$game" == "blood/cryptic.ini" ]]; then
                addPort "$md_id" "${game%/*}" "${games[$game]}" "$cmd -%ROM%" "cryptic"
            # Add Redneck Rampage: Suckin' Grits on Route 66
            elif [[ "$game" == "redneck/game66.con" ]]; then
                addPort "$md_id" "${game%/*}" "${games[$game]}" "$cmd -%ROM%" "route66"
            # Add Games Which Do Not Require Additional Parameters
            else
                addPort "$md_id" "${game%/*}" "${games[$game]}" "$cmd -iwad %ROM%" "${game#*/}"
            fi
        fi
    done
}

function configure_raze() {
    local dirs=(
        'blood'
        'duke3d' 
        'exhumed'
        'nam'
        'redneck'
        'redneckrides'
        'shadow'
        'ww2gi' 
    )
    for dir in "${dirs[@]}"; do
        mkRomDir "ports/$dir"
    done

    moveConfigDir "$home/.config/raze" "$md_conf_root/raze"

    [[ "$md_mode" == "install" ]] && _add_games_raze "$md_inst/raze +vid_renderer 1 +vid_fullscreen 1"
}
