#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="bombermaaan"
rp_module_desc="Bombermaaan - Bomberman Clone"
rp_module_licence="GPL3 https://raw.githubusercontent.com/bjaraujo/Bombermaaan/master/LICENSE.txt"
rp_module_repo="git https://github.com/bjaraujo/Bombermaaan.git :_get_branch_bombermaaan"
rp_module_section="exp"
rp_module_flags="sdl1 !mali"

function _get_branch_bombermaaan() {
    download https://api.github.com/repos/bjaraujo/Bombermaaan/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_bombermaaan() {
    getDepends cmake sdl sdl_mixer
}

function sources_bombermaaan() {
    gitPullOrClone
}

function build_bombermaaan() {
    cd trunk
    cmake . \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DLOAD_RESOURCES_FROM_FILES:BOOL=ON \
        -Wno-dev
    make
    mv bin/Bombermaaan bombermaaan
    md_ret_require="$md_build/trunk/bombermaaan"
}

function install_bombermaaan() {
    md_ret_files=(        
        'trunk/bombermaaan'
        'trunk/levels'
        'trunk/res/images'
        'trunk/res/sounds'
    )
}

function configure_bombermaaan() {
    addPort "$md_id" "bombermaaan" "Bombermaaan" "$md_inst/bombermaaan"

    isPlatform "dispmanx" && setBackend "$md_id" "dispmanx"

    moveConfigDir "$home/.Bombermaaan" "$md_conf_root/bombermaaan"

    local file="$romdir/ports/Bombermaaan.sh"
    cat >"$file" << _EOF_
#!/bin/bash
pushd "$md_inst"
"$rootdir/supplementary/runcommand/runcommand.sh" 0 _PORT_ bombermaaan ""
popd
_EOF_
    chown $user:$user "$file"
    chmod a+x "$file"
}
