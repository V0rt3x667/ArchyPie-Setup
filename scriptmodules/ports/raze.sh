#!/usr/bin/bash -x

# This file is part of the ArchyPie project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

rp_module_id="raze"
rp_module_desc="Raze - Build Engine Port"
rp_module_help="ROM Extensions: .grp\n\nCopy Your .grp files to $romdir/ports/{blood,duke3d,exhumed,redneck,sw,wh}"
rp_module_licence="NONCOM: https://raw.githubusercontent.com/coelckers/Raze/master/build-doc/buildlic.txt"
rp_module_repo="git https://github.com/coelckers/raze.git :_get_branch_raze"
rp_module_section="opt"

function _get_branch_raze() {
    download https://api.github.com/repos/coelckers/raze/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_raze() {
    depends=(
        'alsa-lib'
        'cmake'
        'fluidsynth'
        'gtk3'
        'libjpeg-turbo'
        'openal'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_raze() {
    gitPullOrClone
}

function build_raze() {
    _build_zmusic_gzdoom
    cd "$md_build"
    LDFLAGS+="-Wl,-rpath='$md_inst'"
    cmake . \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DINSTALL_PK3_PATH="$md_inst" \
        -DDYN_GTK=OFF \
        -DDYN_OPENAL=OFF \
        -DZMUSIC_INCLUDE_DIR="$md_build/zmusic/include" \
        -DZMUSIC_LIBRARIES="$md_build/zmusic/source/libzmusic.so"
    make clean
    make
    md_ret_require="$md_build/raze"
}

function install_raze() {
    md_ret_files=(
        'raze'
        'raze.pk3'
        'soundfonts'
        'package/common/gamecontrollerdb.txt'
        'package/common/gpl-2.0.txt'
        'package/common/buildlic.txt'
    )
    cd zmusic/source
    mv libzmusic.so.1.1.8 "$md_inst/libzmusic.so"
    mv libzmusiclite.so.1.1.8 "$md_inst/libzmusiclite.so"
}

function _add_games_raze() {
    local cmd="$1"
    local game

    declare -A games=(
        ['blood/blood.rff']="Blood"
        ['blood/cryptic.ini']="Blood - Cryptic Passage"
        ['duke3d/duke3d.grp']="Duke Nukem 3D"
        ['duke3d/dukedc.grp']="Duke Nukem 3D - Duke It Out in D.C."
        ['duke3d/vacation.grp']="Duke Nukem 3D - Duke Caribbean - Life's a Beach"
        ['duke3d/nwinter.grp']="Duke Nukem 3D - Duke - Nuclear Winter"
        ['exhumed/stuff.dat']="Exhumed (AKA PowerSlave)"
        ['nam/nam.grp']="NAM (AKA Napalm)"
        ['nam/napalm.grp']="Napalm (AKA NAM)"
        ['redneck/redneck.grp']="Redneck Rampage"
        ['redneck/game66.con']="Redneck Rampage - Suckin' Grits on Route 66"
        ['redneckrides/redneck.grp']="Redneck Rampage - Redneck Rampage Rides Again"
        ['shadow/sw.grp']="Shadow Warrior"
        ['shadow/td.grp']="Shadow Warrior - Twin Dragon"
        ['shadow/wt.grp']="Shadow Warrior - Wanton Destruction"
        ['ww2gi/ww2gi.grp']="World War II GI"
        ['ww2gi/platoonl.dat']="World War II GI - Platoon Leader"
    )

    for game in "${!games[@]}"; do
        local file="$romdir/ports/$game"
        local grp="${game#*/}"
        # Add Games Which Do Not Require Additional Parameters
        if [[ "$game" != blood/cryptic.ini && "$game" != redneck/game66.con && -f "$file" ]]; then
            addPort "$md_id" "${game#*/}" "${games[$game]}" "$cmd -iwad $grp"
        # Add Blood: Cryptic Passage
        elif [[ "${game}" == blood/cryptic.ini && -f "$file" ]]; then
            addPort "$md_id" "${game#*/}" "${games[$game]}" "$cmd -cryptic"
        # Add Redneck Rampage: Suckin' Grits on Route 66
        elif [[ "${game}" == redneck/game66.con && -f "$file" ]]; then
            addPort "$md_id" "${game#*/}" "${games[$game]}" "$cmd -route66"
        fi
    done
}

function configure_raze() {
    local dir=(
        'blood'
        'duke3d' 
        'exhumed'
        'nam'
        'redneck'
        'redneckrides'
        'shadow'
        'ww2gi' 
    )
    for d in "${dir[@]}"; do
        mkRomDir "ports/$d"
    done
    moveConfigDir "$home/.config/raze" "$md_conf_root/raze"

    [[ "$md_mode" == "install" ]] && _add_games_raze "$md_inst/raze +vid_renderer 1 +vid_fullscreen 1"
}
