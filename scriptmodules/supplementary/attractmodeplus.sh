#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="attractmodeplus"
rp_module_desc="Attract-Mode Plus: Emulator Frontend"
rp_module_licence="GPL3 https://raw.githubusercontent.com/oomek/attractplus/master/License.txt"
rp_module_repo="git https://github.com/oomek/attractplus :_get_branch_attractmodeplus"
rp_module_section="exp"
rp_module_flags="frontend"

function _get_branch_attractmodeplus() {
    echo "master"
}

function _get_configdir_attractmodeplus() {
    echo "${configdir}/all/attractmodeplus"
}

function _add_system_attractmodeplus() {
    local attractplus_dir

    attractplus_dir="$(_get_configdir_attractmodeplus)"
    [[ ! -d "${attractplus_dir}" || ! -f "/usr/bin/attractplus" ]] && return 0

    local fullname="${1}"
    local name="${2}"
    local path="${3}"
    local extensions="${4}"
    local command="${5}"
    local platform="${6}"
    local theme="${7}"

    # Replace any '/' characters in fullname
    fullname="${fullname//\/}"

    local config="${attractplus_dir}/emulators/${fullname}.cfg"
    iniConfig " " "" "${config}"
    # Replace %ROM% with "[romfilename]" & convert to an array
    # shellcheck disable=SC2206
    command=(${command//%ROM%/\"[romfilename]\"})
    iniSet "executable" "${command[0]}"
    iniSet "args" "${command[*]:1}"

    iniSet "rompath" "${path}"
    iniSet "system" "${fullname}"

    # Extensions separated by semicolons
    extensions="${extensions// /;}"

    iniSet "romext" "${extensions}"

    # Snap path
    local snap="snap"
    [[ "${name}" == "archypie" ]] && snap="icons"
    iniSet "artwork flyer" "${path}/flyer"
    iniSet "artwork marquee" "${path}/marquee"
    iniSet "artwork snap" "${path}/${snap}"
    iniSet "artwork wheel" "${path}/wheel"

    chown "${__user}":"${__group}" "${config}"

    # If no gameslist generate one
    if [[ ! -f "${attractplus_dir}/romlists/${fullname}.txt" ]] && [[ -f "/usr/bin/attractplus" ]]; then
        sudo -u "${__user}" attractplus --build-romlist "${fullname}" -o "${fullname}"
    else
        return
    fi

    local config="${attractplus_dir}/attract.cfg"
    local tab=$'\t'
    if [[ -f "${config}" ]] && ! grep -q "display${tab}${fullname}" "${config}"; then
        cp "${config}" "${config}.bak"
        cat >>"${config}" <<_EOF_
display${tab}${fullname}
${tab}layout               Basic
${tab}romlist              ${fullname}
_EOF_
        chown "${__user}":"${__group}" "${config}"*
    fi
}

function _del_system_attractmodeplus() {
    local attractplus_dir
    attractplus_dir="$(_get_configdir_attractmodeplus)"
    [[ ! -d "${attractplus_dir}" ]] && return 0

    local fullname="${1}"
    local name="${2}"

    # Don't remove an empty system
    [[ -z "${fullname}" ]] && return 0

    # Replace any '/' characters in fullname
    fullname="${fullname//\/}"

    rm -rf "${attractplus_dir}/romlists/${fullname}.txt"

    local tab=$'\t'
    # Remove display block from "^display${tab}${fullname}" to next "^display" or empty line keeping the next display line
    sed -i "/^display${tab}${fullname}/,/^display\|^$/{/^display${tab}${fullname}/d;/^display\$/!d}" "${attractplus_dir}/attract.cfg"
}

function _add_rom_attractmodeplus() {
    local attractplus_dir
    attractplus_dir="$(_get_configdir_attractmodeplus)"
    [[ ! -d "${attractplus_dir}" ]] && return 0

    local system_name="${1}"
    local system_fullname="${2}"
    local path="${3}"
    local name="${4}"
    local desc="${5}"
    local image="${6}"

    local config="${attractplus_dir}/romlists/${system_fullname}.txt"

    # Remove extension
    path="${path/%.*}"

    if [[ ! -f "${config}" ]]; then
        echo "#Name;Title;Emulator;CloneOf;Year;Manufacturer;Category;Players;Rotation;Control;Status;DisplayCount;DisplayType;AltRomname;AltTitle;Extra;Buttons" >"${config}"
    fi

    # If the entry already exists, remove it
    if grep -q "^${path};" "${config}"; then
        sed -i "/^${path}/d" "${config}"
    fi

    echo "${path};${name};${system_fullname};;;;;;;;;;;;;;" >>"${config}"
    chown "${__user}":"${__group}" "${config}"
}

function depends_attractmodeplus() {
    depends_attractmode
}

function sources_attractmodeplus() {
    gitPullOrClone

    # Set default config path(s)
    sed -e "s|/.attract|/ArchyPie/configs/${md_id}|g" -i "${md_build}/src/fe_settings.cpp"

    # Do not build vendored 'sfml'
    if isPlatform "kms"; then
        applyPatch "${md_data}/01_fix_sfml_build.patch"
    fi

    # Get 'sfml' source code for the 'kms' platform
    if isPlatform "kms"; then
        _sources_sfml_attractmode
    fi
}

function build_attractmodeplus() {
    # Build 'sfml' for the 'kms' platform
    if isPlatform "kms"; then
        _build_sfml_attractmode
    fi

    # Build 'attract-mode plus'
    echo "*** Building Attract-Mode Plus ***"
    # We don't want to build the bundled 'sfml' on the 'kms' platform
    local params=()
    isPlatform "kms" && params+=('USE_DRM=1' 'USE_SYSTEM_SFML=1' EXTRA_CFLAGS="${CFLAGS} -I${md_build}/sfml/build/include -L${md_build}/sfml/build/lib")
    isPlatform "rpi" && params+=('USE_MMAL=1')
    isPlatform "x11" && params+=('USE_SYSTEM_SFML=1')
    isPlatform "x86" && params+=('FE_HWACCEL_VAAPI=1' 'FE_HWACCEL_VDPAU=1')

    make clean
    make prefix="${md_inst}" "${params[@]}"

    # Remove example configs
    rm -rf "${md_build}/config/emulators/"*

    md_ret_require="${md_build}/attractplus"
}

function install_attractmodeplus() {
    # Install 'attract-mode plus'
    echo "*** Installing Attract-Mode Plus ***"
    make prefix="${md_inst}" install

    # Install 'sfml' for the 'kms' platform
    if isPlatform "kms"; then
        _install_sfml_attractmode
    fi
}

function remove_attractmodeplus() {
    rm -f "/usr/bin/attractplus"
}

function configure_attractmodeplus() {
    moveConfigDir "${arpdir}/${md_id}"  "${md_conf_root}/all/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        # Create default config file
        local config="${md_conf_root}/all/${md_id}/attract.cfg"

        if [[ ! -f "${config}" ]]; then
            echo "general" >"${config}"
            echo -e "\twindow_mode          fullscreen" >>"${config}"
        fi
        chown "${__user}":"${__group}" "${config}"

        mkUserDir "${md_conf_root}/all/${md_id}/emulators"

        # Create launcher script
        cat > "/usr/bin/attractplus" <<_EOF_
#!/usr/bin/env bash
MODELIST=/opt/archypie/supplementary/kmsxx/kmsprint-rp
if [[ -z "\${DISPLAY}" && -f "\${MODELIST}" && ! "\${1}" =~ build-romlist ]]; then
    MODELIST="\$(\${MODELIST} 2>/dev/null)"
    default_mode="\$(echo "\${MODELIST}" | grep -Em1 "^Mode: [0-9]+ crtc" | grep -oE [0-9]+x[0-9]+)"
    default_vrefresh="\$(echo "\${MODELIST}" | grep -Em1 "^Mode: [0-9]+ crtc" | grep -oE [0-9]+Hz)"
    # Strip Hz from the refresh rate
    default_vrefresh="\${default_vrefresh%Hz}"
    echo "Using default video mode: \${default_mode} @ \${default_vrefresh}"

    [[ ! -z "\${default_mode}" ]] && export SFML_DRM_MODE="\${default_mode}"
    [[ ! -z "\${default_vrefresh}" ]] && export SFML_DRM_REFRESH="\${default_vrefresh}"
fi
"${md_inst}/bin/attractplus" "\${@}"
_EOF_
    chmod +x "/usr/bin/attractplus"

        local id
        for id in "${__mod_id[@]}"; do
            if rp_isInstalled "${id}" && [[ -n "${__mod_info[${id}/section]}" ]] && ! hasFlag "${__mod_info[${id}/flags]}" "frontend"; then
                rp_callModule "${id}" configure
            fi
        done
    fi
}
