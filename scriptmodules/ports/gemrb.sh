#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="gemrb"
rp_module_desc="GemRB: Port of Bioware's Infinity Engine"
rp_module_licence="GPL2 https://raw.githubusercontent.com/gemrb/gemrb/master/COPYING"
rp_module_repo="git https://github.com/gemrb/gemrb :_get_branch_gemrb"
rp_module_section="exp"
rp_module_flags="!mali"

function _get_branch_gemrb() {
    download "https://api.github.com/repos/gemrb/gemrb/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_gemrb() {
    local depends=(
        'cmake'
        'glew'
        'libpng'
        'libvorbis'
        'ninja'
        'openal'
        'python'
        'sdl2'
        'vlc'
    )
    getDepends "${depends[@]}"
}

function sources_gemrb() {
    gitPullOrClone
}

function build_gemrb() {
    local params
    ! isPlatform "wayland" && isPlatform "gl" && params+=('-DOPENGL_BACKEND=OpenGL')
    
    cmake . \
        -GNinja \
        -Bbuild \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DFREETYPE_INCLUDE_DIRS=/usr/include/freetype2/ \
        -DSDL_BACKEND=SDL2 \
        -DUSE_SDLMIXER=OFF \
        "${params[@]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}/${md_id}"
}

function install_gemrb() {
    ninja -C build install/strip
}

function configure_gemrb() {
    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'baldursgate1'
            'baldursgate2'
            'icewind1'
            'icewind2'
            'planescape'
        )
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${md_id}/${dir}"
            mkUserDir "${arpdir}/${md_id}/${dir}"
        done
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    # Create Baldurs Gate 1 Configuration
    cat > "${md_conf_root}/${md_id}/baldursgate1/GemRB.cfg" << _EOF_
GameType=bg1
GameName=Baldur's Gate
Width=640
Height=480
Bpp=32
Fullscreen=1
TooltipDelay=500
AudioDriver = openal
GUIEnhancements = 15
DrawFPS=0
CaseSensitive=1
GamePath=${romdir}/ports/${md_id}/baldursgate1/
CD1=${romdir}/ports/${md_id}/baldursgate1/
CachePath=${romdir}/ports/${md_id}/baldursgate1/cache/
_EOF_

    # Create Baldurs Gate 2 Configuration
    cat > "${md_conf_root}/${md_id}/baldursgate2/GemRB.cfg" << _EOF_
GameType=bg2
GameName=Baldur's Gate II: Shadows of Amn
Width=640
Height=480
Bpp=32
Fullscreen=1
TooltipDelay=500
AudioDriver = openal
GUIEnhancements = 15
DrawFPS=0
CaseSensitive=1
GamePath=${romdir}/ports/${md_id}/baldursgate2/
CD1=${romdir}/ports/${md_id}/baldursgate2/data/
CD2=${romdir}/ports/${md_id}/baldursgate2/data/
CD3=${romdir}/ports/${md_id}/baldursgate2/data/
CD4=${romdir}/ports/${md_id}/baldursgate2/data/
CD5=${romdir}/ports/${md_id}/baldursgate2/data/
CD6=${romdir}/ports/${md_id}/baldursgate2/data/
CachePath=${romdir}/ports/${md_id}/baldursgate2/cache
_EOF_

    # Create Icewind 1 Configuration
    cat > "${md_conf_root}/${md_id}/icewind1/GemRB.cfg" << _EOF_
GameType=auto
GameName=Icewind Dale
Width=640
Height=480
Bpp=32
Fullscreen=1
TooltipDelay=500
AudioDriver = openal
GUIEnhancements = 15
DrawFPS=0
CaseSensitive=1
GamePath=${romdir}/ports/${md_id}/icewind1/
CD1=${romdir}/ports/${md_id}/icewind1/Data/
CD2=${romdir}/ports/${md_id}/icewind1/CD2/Data/
CD3=${romdir}/ports/${md_id}/icewind1/CD3/Data/
CachePath=${romdir}/ports/${md_id}/icewind1/cache/
_EOF_

    # Create Icewind2 Configuration
    cat > "${md_conf_root}/${md_id}/icewind2/GemRB.cfg" << _EOF_
GameType=iwd2
GameName=Icewind Dale II
Width=800
Height=600
Bpp=32
Fullscreen=1
TooltipDelay=500
AudioDriver = openal
GUIEnhancements = 15
DrawFPS=0
CaseSensitive=1
GamePath=${romdir}/ports/${md_id}/icewind2/
CD1=${romdir}/ports/${md_id}/icewind2/data/
CachePath=${romdir}/ports/${md_id}/icewind2/cache/
_EOF_

    # Create Planescape Configuration
    cat > "${md_conf_root}/${md_id}/planescape/GemRB.cfg" << _EOF_
GameType=pst
GameName=Planescape Torment
Width=640
Height=480
Bpp=32
Fullscreen=1
TooltipDelay=500
AudioDriver = openal
GUIEnhancements = 15
DrawFPS=0
CaseSensitive=1
GamePath=${romdir}/ports/${md_id}/planescape/
CD1=${romdir}/ports/${md_id}/planescape/data/
CachePath=${romdir}/${md_id}/ports/planescape/cache/
_EOF_

    chown -R "${user}:${user}" "${md_conf_root}/${md_id}"

    addPort "${md_id}" "baldursgate1" "Baldur's Gate" "${md_inst}/bin/${md_id} -C ${md_conf_root}/${md_id}/baldursgate1/GemRB.cfg"
    addPort "${md_id}" "baldursgate2" "Baldur's Gate II: Shadows of Amn" "${md_inst}/bin/${md_id} -C ${md_conf_root}/${md_id}/baldursgate2/GemRB.cfg"
    addPort "${md_id}" "icewind1" "Icewind Dale" "${md_inst}/bin/${md_id} -C ${md_conf_root}/${md_id}/icewind1/GemRB.cfg"
    addPort "${md_id}" "icewind2" "Icewind Dale II" "${md_inst}/bin/${md_id} -C ${md_conf_root}/${md_id}/icewind2/GemRB.cfg"
    addPort "${md_id}" "planescape" "Planescape Torment" "${md_inst}/bin/${md_id} -C ${md_conf_root}/${md_id}/planescape/GemRB.cfg"
}
