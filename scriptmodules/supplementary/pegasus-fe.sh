#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="pegasus-fe"
rp_module_desc="Pegasus: A Cross Platform Graphical Frontend"
rp_module_help="Pegasus is a cross platform, customizable graphical frontend for launching emulators & managing your game collection."
rp_module_licence="GPL3 https://raw.githubusercontent.com/mmatyas/pegasus-frontend/master/LICENSE.md"
rp_module_repo="git https://github.com/mmatyas/pegasus-frontend master"
rp_module_section="exp"
rp_module_flags="frontend"

function depends_pegasus-fe() {
    local depends=(
        'gst-libav'
        'gst-plugins-good'
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

    # On KMS Apply A Patch To Fix Launching Games
    isPlatform "kms" && applyPatch "${md_build}/etc/rpi4/kms_launch_fix.diff"
}

function build_pegasus-fe() {
    qmake . \
        INSTALLDIR="${md_inst}" \
        QMAKE_CXXFLAGS+="${__cxxflags}" \
        QMAKE_LIBS_LIBDL=-ldl \
        USE_SDL_GAMEPAD=1 \
        USE_SDL_POWER=1
    make clean
    make

    md_ret_require="${md_build}/src/app/${md_id}"
}

function install_pegasus-fe() {
    make install
    _add_launcher_pegasus-fe
}

function _add_launcher_pegasus-fe() {
    cat > /usr/bin/pegasus-fe << _EOF_
#!/bin/bash

if [[ \$(id -u) -eq 0 ]]; then
    echo "Pegasus should not be run as root. If you used 'sudo pegasus-fe' please run without sudo."
    exit 1
fi
_EOF_

    # On KMS Platforms Add Additional Setup Commands
    if isPlatform "kms"; then
        cat >> /usr/bin/pegasus-fe << _EOF_
# KMS Setup
export QT_QPA_EGLFS_FORCE888=1  # Improve Gradients
export QT_QPA_EGLFS_KMS_ATOMIC=1  # Use The Atomic DRM API On Pi 4
export QT_QPA_PLATFORM=eglfs
export QT_QPA_QT_QPA_EGLFS_INTEGRATION=eglfs_kms

# Find The Right DRI Card
for i in \$(find /sys/devices/platform -name "card?"); do
    node=\${i:0-1}
    case "\${i}" in
        *gpu*)  card=\${node} ;;
    esac
done

echo Using DRI Card At /dev/dri/card\${card}
file="/tmp/pegasus_\$\$.eglfs.json"
echo "{ \"device\": \"/dev/dri/card\${card}\" }" > "\${file}"
export QT_QPA_EGLFS_KMS_CONFIG="\${file}"
_EOF_
    fi

    cat >> /usr/bin/pegasus-fe << _EOF_
clear
"${md_inst}/pegasus-fe" "\${@}"

rm -f "/tmp/pegasus_\$\$.eglfs.json"
_EOF_

    chmod +x /usr/bin/pegasus-fe
}

function _update_themes_pegasus-fe() {
    echo Installing Themes
    declare themes=(
        "mmatyas/pegasus-theme-9999999-in-1"
        "mmatyas/pegasus-theme-es2-simple"
        "mmatyas/pegasus-theme-flixnet"
        "mmatyas/pegasus-theme-secretary"
    )
    local theme
    pushd "${home}/.config/pegasus-frontend/themes" || exit
    for theme in "${themes[@]}"; do
        local path=${theme//"mmatyas/pegasus-theme-"/}
        gitPullOrClone "${path}" "https://github.com/${theme}"
    done
    popd || exit
}

function remove_pegasus-fe() {
    rm -f /usr/bin/pegasus-fe
}

function configure_pegasus-fe() {
    moveConfigDir "${home}/.config/pegasus-frontend" "${md_conf_root}/all/pegasus-fe"

    if [[ "${md_mode}" == "install" ]]; then
        # Create External Directories
        mkUserDir "${md_conf_root}/all/pegasus-fe/scripts"
        mkUserDir "${md_conf_root}/all/pegasus-fe/themes"

        # Install Themes
        _update_themes_pegasus-fe
    fi
}
