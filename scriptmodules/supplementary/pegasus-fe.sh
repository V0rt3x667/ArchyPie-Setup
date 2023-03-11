#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="pegasus-fe"
rp_module_desc="Pegasus: A Cross Platform Graphical Frontend (Latest Alpha Release)"
rp_module_licence="GPL3 https://raw.githubusercontent.com/mmatyas/pegasus-frontend/master/LICENSE.md"
rp_module_repo="git https://github.com/mmatyas/pegasus-frontend master"
rp_module_section="exp"
rp_module_flags="frontend"

function depends_pegasus-fe() {
    local depends=(
        'gst-libav'
        'gst-plugins-good'
        'jq'
        'polkit'
        'qt5-declarative'
        'qt5-gamepad'
        'qt5-graphicaleffects'
        'qt5-imageformats'
        'qt5-multimedia'
        'qt5-quickcontrols'
        'qt5-svg'
        'qt5-tools'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_pegasus-fe() {
    gitPullOrClone
}

function build_pegasus-fe() {
    qmake . \
        USE_SDL_GAMEPAD=1
    make clean
    make
    md_ret_require="${md_build}/src/app/${md_id}"
}

function install_pegasus-fe() {
    md_ret_files=("src/app/${md_id}")
}

function remove_pegasus-fe() {
    rm -f /usr/bin/pegasus-fe
}

function configure_pegasus-fe() {
    moveConfigDir "${home}/.config/pegasus-frontend" "${md_conf_root}/all/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        # Create External Directories
        mkUserDir "${md_conf_root}/all/pegasus-fe/scripts"
        mkUserDir "${md_conf_root}/all/pegasus-fe/themes"

        # Create Launcher Script
        cat > /usr/bin/pegasus-fe << _EOF_
#!/bin/bash

if [[ \$(id -u) -eq 0 ]]; then
    echo "Pegasus should not be run as root. If you used 'sudo pegasus-fe' please run without sudo."
    exit 1
fi

# Save Current TTY/VT Number For Use With X So It Can Be Launched On The Correct TTY
tty=\$(tty)
export TTY="\${tty:8:1}"

export QT_QPA_EGLFS_FORCE888=1  # Improve Gradients
export QT_QPA_EGLFS_KMS_ATOMIC=1  # Use The Atomic DRM API On Pi 4

clear
"${md_inst}/pegasus-fe" "\$@"
_EOF_
        chmod +x /usr/bin/pegasus-fe
    fi
}
