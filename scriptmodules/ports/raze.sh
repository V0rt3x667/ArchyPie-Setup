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
        'openal'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_raze() {
    gitPullOrClone
    applyPatch "$md_data/01_fix_file_paths.patch"
}

function build_raze() {
    _build_zmusic

    cd "$md_build"
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
        -DZMUSIC_LIBRARIES="$md_build/zmusic/build/source/libzmusic.so" \
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
    install -Dm644 "$md_build"/zmusic/build/source/libzmusic* -t "$md_inst/lib"
}

function _add_games_raze() {
    local binary="$1"
    local game
    local game_args
    local game_launcher
    local game_path
    local game_portname
    local num_games=16

    local game0=('Blood' 'blood' '-iwad blood.rff')
    local game1=('Blood: Cryptic Passage' 'blood' '-cryptic')
    local game2=('Duke Nukem 3D' 'duke3d' '-addon 0')
    local game3=('Duke Nukem 3D: Duke It Out In D.C.' 'duke3d' '-addon 1')
    local game4=('Duke Nukem 3D: Duke: Nuclear Winter' 'duke3d' '-addon 2')
    local game5=('Duke Nukem 3D: Duke Caribbean: Life'\''s a Beach' 'duke3d' '-addon 3')
    local game6=('Exhumed-PowerSlave' 'exhumed' '-iwad stuff.dat')
    local game7=('Napalm' 'nam' '-napalm')
    local game8=('NAM' 'nam' '-nam')
    local game9=('Redneck Rampage' 'redneck' '-iwad redneck.grp')
    local game10=('Redneck Rampage: Suckin'\'' Grits on Route 66' 'redneck' '-route66')
    local game11=('Redneck Rampage: Redneck Rampage Rides Again' 'redneck' '-iwad rides.grp')
    local game12=('Shadow Warrior' 'shadow' '-iwad sw.grp')
    local game13=('Shadow Warrior: Twin Dragon' 'shadow' '-iwad td.grp')
    local game14=('Shadow Warrior: Wanton Destruction' 'shadow' '-iwad wt.grp')
    local game15=('World War II GI' 'ww2gi' '-ww2gi')
    local game16=('World War II GI: Platoon Leader' 'ww2gi' '-iwad platoonl.dat')

    for ((game=0;game<=num_games;game++)); do
        game_launcher="game$game[0]"
        game_portname="game$game[1]"
        game_path="game$game[1]"
        game_args="game$game[2]"
        if [[ -d "$romdir/ports/${!game_path}" ]]; then
           addPort "$md_id" "${!game_portname}" "${!game_launcher}" "${binary}.sh %ROM%" "${!game_args}"
        fi
    done

    if [[ "$md_mode" == "install" ]]; then
        # we need to use a dumb launcher script to strip quotes from runcommand's generated arguments
        cat > "${binary}.sh" << _EOF_
#!/bin/bash
$md_inst/raze +vid_renderer 1 +vid_fullscreen 1 \$*
_EOF_
        chmod +x "${binary}.sh"
    fi
}

function configure_raze() {
    local dir=(
        'blood'
        'duke3d' 
        'exhumed'
        'nam'
        'redneck'
        'shadow'
        'ww2gi' 
    )
    for d in "${dir[@]}"; do
        mkRomDir "ports/$d"
    done

    [[ "$md_mode" == "install" ]] && _add_games_raze "$md_inst/raze"
}
