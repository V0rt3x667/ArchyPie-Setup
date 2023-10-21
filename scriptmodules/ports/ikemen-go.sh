#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ikemen-go"
rp_module_desc="I.K.E.M.E.N GO: M.U.G.E.N Game Engine"
rp_module_licence="MIT https://raw.githubusercontent.com/ikemen-engine/Ikemen-GO/master/License.txt"
rp_module_help="ROM Extensions: .mgn\n\nCopy Game Folder To: ${romdir}/mugen & Create An Empty File Named After The Folder Plus .mgn Suffix"
rp_module_repo="git https://github.com/ikemen-engine/Ikemen-GO :_get_branch_ikemen-go"
rp_module_section="exp"
rp_module_flags="!all x11 xwayland"

function _get_branch_ikemen-go() {
    download "https://api.github.com/repos/ikemen-engine/Ikemen-GO/releases" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_ikemen-go() {
    local depends=(
        'go'
        'mesa'
        'openal'
    )
    getDepends "${depends[@]}"
}

function sources_ikemen-go() {
    gitPullOrClone
}

function build_ikemen-go() {
    go clean -modcache
    go build -v -tags al_cmpt -o Ikemen_GO ./src

    md_ret_require="${md_build}/Ikemen_GO"
}

function install_ikemen-go() {
    md_ret_files=('Ikemen_GO')
}

function configure_ikemen-go() {
    setConfigRoot ""

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "mugen"

        # Create Launcher Script
        cat >"${md_inst}/ikemen-go.sh" << _EOF_
#!/usr/bin/env bash
BASENAME=\${1}
cd "${romdir}/mugen/\${BASENAME}" && "${md_inst}/Ikemen_GO"
_EOF_
        chmod +x "${md_inst}/ikemen-go.sh"
    fi

    addEmulator 1 "${md_id}" "mugen" "${md_inst}/ikemen-go.sh %BASENAME%"

    addSystem "mugen"
}
