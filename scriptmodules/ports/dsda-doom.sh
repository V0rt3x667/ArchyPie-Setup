#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dsda-doom"
rp_module_desc="DSDA-Doom: Lightweight Doom Source Port"
rp_module_licence="GPL2 https://raw.githubusercontent.com/kraflab/dsda-doom/master/prboom2/COPYING"
rp_module_repo="git https://github.com/kraflab/dsda-doom :_get_branch_dsda-doom"
rp_module_section="exp"
rp_module_flags=""

function _get_branch_dsda-doom() {
    download "https://api.github.com/repos/kraflab/dsda-doom/releases" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_dsda-doom() {
    local depends=(
        'alsa-lib'
        'clang'
        'cmake'
        'dumb'
        'libglvnd'
        'libmad'
        'libogg'
        'libvorbis'
        'libzip'
        'lld'
        'ninja'
        'sdl2_image'
        'sdl2_mixer'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_dsda-doom() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|\"/.dsda-doom\"|\"/ArchyPie/configs/${md_id}\"|g" -i "${md_build}/prboom2/src/SDL/i_system.c"
}

function build_dsda-doom() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -S"prboom2" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DENABLE_LTO="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/dsda-doom"
}

function install_dsda-doom() {
    ninja -C build install/strip
}

function configure_dsda-doom() {
    local portname
    portname=doom

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'addons'
            'addons/hell'
            'addons/lost'
            'addons/masterlevels'
            'addons/misc'
            'addons/nerve'
            'addons/perdition'
            'addons/sigil'
            'addons/strain'
            'chex'
            'doom1'
            'doom2'
            'finaldoom'
            'freedoom'
            'hacx'
            'heretic'
        )
        mkRomDir "ports/${portname}"
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${portname}/${dir}"
        done

        _game_data_lr-prboom
    fi

    # Create A Launcher Script To Strip Quotes From 'runcommand.sh' Generated Arguments
    local launcher_prefix="DOOMWADDIR=${romdir}/ports/${portname}"
    local params=("-fullscreen" "-width %XRES%" "-height %YRES%")

    cat > "${md_inst}/${md_id}.sh" << _EOF_
#!/usr/bin/env bash
${launcher_prefix} ${md_inst}/bin/${md_id} -iwad \${*}
_EOF_
    chmod +x "${md_inst}/${md_id}.sh"

    _add_games_lr-prboom "${md_inst}/${md_id}.sh %ROM% ${params[*]}"
}
