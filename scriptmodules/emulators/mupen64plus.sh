#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="mupen64plus"
rp_module_desc="MUPEN64Plus: Nintendo N64 Emulator"
rp_module_help="ROM Extensions: .n64 .v64 .z64\n\nCopy N64 ROMs To: ${romdir}/n64"
rp_module_licence="GPL2 https://raw.githubusercontent.com/mupen64plus/mupen64plus-core/master/LICENSES"
rp_module_repo=":_pkg_info_mupen64plus"
rp_module_section="main"
rp_module_flags=""

function depends_mupen64plus() {
    local depends=(
        'boost'
        'cmake'
        'freetype2'
        'libsamplerate'
        'minizip'
        'sdl2'
        'speexdsp'
)
    isPlatform "gl" && depends+=('glew' 'glu')
    isPlatform "mesa" && depends+=('libglvnd')
    isPlatform "rpi" && depends+=('raspberrypi-firmware')
    isPlatform "x86" && depends+=('nasm')

    getDepends "${depends[@]}"
}

function _get_repos_mupen64plus() {
    local repos=(
        'mupen64plus mupen64plus-audio-sdl master'
        'mupen64plus mupen64plus-core master'
        'mupen64plus mupen64plus-input-sdl master'
        'mupen64plus mupen64plus-rsp-hle master'
        'mupen64plus mupen64plus-ui-console master'
    )

    if isPlatform "rpi" && isPlatform "32bit"; then
        repos+=('gizmo98 mupen64plus-audio-omx master')
    fi

    if isPlatform "gles"; then
        ! isPlatform "rpi" && repos+=('mupen64plus mupen64plus-video-glide64mk2 master')
        if isPlatform "32bit"; then
            repos+=('ricrpi mupen64plus-video-gles2rice pandora-backport')
            repos+=('ricrpi mupen64plus-video-gles2n64 master')
        fi
    fi

    if isPlatform "gl"; then
        repos+=(
            'gonetz GLideN64 master'
            'mupen64plus mupen64plus-rsp-cxd4 master'
            'mupen64plus mupen64plus-rsp-z64 master'
            'mupen64plus mupen64plus-video-glide64mk2 master'
        )
    fi

    local repo
    for repo in "${repos[@]}"; do
        echo "${repo}"
    done
}

function _pkg_info_mupen64plus() {
    local mode="$1"
    local repo
    case "${mode}" in
        get)
            local hashes=()
            local hash
            local date
            local newest_date
            while read -r repo; do
                repo=(${repo}) # Do Not Quote
                date=$(git -C "${md_build}/${repo[1]}" log -1 --format=%aI)
                hash="$(git -C "${md_build}/${repo[1]}" log -1 --format=%H)"
                hashes+=("${hash}")
                if rp_dateIsNewer "${newest_date}" "${date}"; then
                    newest_date="${date}"
                fi
            done < <(_get_repos_mupen64plus)
            # Store An 'md5sum' Of The Last Commit Hashes, Used To Check For Changes
            local hash
            hash="$(echo "${hashes[@]}" | md5sum | cut -d" " -f1)"
            echo "local pkg_repo_date=\"${newest_date}\""
            echo "local pkg_repo_extra=\"${hash}\""
            ;;
        newer)
            local hashes=()
            local hash
            while read -r repo; do
                repo=(${repo}) # Do Not Quote
                # If Repos Set To A Specific Git Hash (eg GLideN64) Use That Otherwise Check
                if [[ -n "${repo[3]}" ]]; then
                    hash="${repo[3]}"
                else
                    if ! hash="$(rp_getRemoteRepoHash git https://github.com/${repo[0]}/${repo[1]} ${repo[2]})"; then
                        __ERRMSGS+=("${hash}")
                        return 3
                    fi
                fi
                hashes+=("${hash}")
            done < <(_get_repos_mupen64plus)
            # Store An 'md5sum' Of The Last Commit Hashes, Used To Check For Changes
            local hash
            hash="$(echo "${hashes[@]}" | md5sum | cut -d" " -f1)"
            if [[ "${hash}" != "${pkg_repo_extra}" ]]; then
                return 0
            fi
            return 1
            ;;
        check)
            local ret=0
            while read -r repo; do
                repo=($repo) # Do Not Quote
                out=$(rp_getRemoteRepoHash git https://github.com/${repo[0]}/${repo[1]} ${repo[2]})
                if [[ -z "$out" ]]; then
                    printMsgs "console" "${id} Repository Failed: https://github.com/${repo[0]}/${repo[1]} ${repo[2]}"
                    ret=1
                fi
            done < <(_get_repos_mupen64plus)
            return "${ret}"
            ;;
    esac
}

function sources_mupen64plus() {
    local repo
    while read -r repo; do
        repo=($repo) # Do not quote
        gitPullOrClone "${md_build}/${repo[1]}" https://github.com/${repo[0]}/${repo[1]} ${repo[2]} ${repo[3]}
    done < <(_get_repos_mupen64plus)

    local config_version
    config_version=$(grep -oP '(?<=CONFIG_VERSION_CURRENT ).+?(?=U)' GLideN64/src/Config.h)
    echo "${config_version}" > "${md_build}/GLideN64_config_version.ini"

    # Set Default Config Path(s)
    sed -e "s|get_xdg_dir(retpath, \"HOME\", \".local/share/mupen64plus/\")|get_xdg_dir(retpath, \"HOME\", \"ArchyPie/configs/${md_id}/\")|g" -i "${md_build}/mupen64plus-core/src/osal/files_unix.c"
}

function build_mupen64plus() {
    rpSwap on 750

    local dir
    local params=()
    for dir in *; do
        if [[ -f "${dir}/projects/unix/Makefile" ]]; then
            params=()
            isPlatform "rpi" || [[ "${dir}" == "mupen64plus-audio-omx" ]] && params+=("VC=1")
            if isPlatform "mesa" || isPlatform "mali"; then
                params+=("USE_GLES=1")
            fi
            isPlatform "neon" && params+=("NEON=1")
            isPlatform "x11" && params+=("OSD=1" "PIE=1")
            isPlatform "x86" && params+=("SSE=SSE2")
            isPlatform "armv7" && params+=("HOST_CPU=armv7")
            isPlatform "aarch64" && params+=("HOST_CPU=aarch64")

            [[ "${dir}" == "mupen64plus-ui-console" ]] && params+=("COREDIR=${md_inst}/lib/" "PLUGINDIR=${md_inst}/lib/mupen64plus/")
            make -C "${dir}/projects/unix" "${params[@]}" clean
            make -C "${dir}/projects/unix" all "${params[@]}" OPTFLAGS="${CFLAGS} -fno-lto"
        fi
    done

    # Build GLideN64
    "${md_build}/GLideN64/src/getRevision.sh"

    params=("-DMUPENPLUSAPI=On" "-DVEC4_OPT=On" "-DUSE_SYSTEM_LIBS=On")
    isPlatform "neon" && params+=("-DNEON_OPT=On")
    isPlatform "mesa" && params+=("-DMESA=On" "-DEGL=On")
    isPlatform "armv8" && params+=("-DCRC_ARMV8=On")
    isPlatform "mali" && params+=("-DCRC_OPT=On" "-DEGL=On")
    isPlatform "x86" && params+=("-DCRC_OPT=On")

    cmake . \
        -S"${md_build}/GLideN64/src" \
        -B"${md_build}/GLideN64/build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        "${params[@]}" \
        -Wno-dev
    ninja -C "${md_build}/GLideN64/build" clean
    ninja -C "${md_build}/GLideN64/build"

    rpSwap off

    md_ret_require=(
        'GLideN64/build/plugin/Release/mupen64plus-video-GLideN64.so'
        'mupen64plus-audio-sdl/projects/unix/mupen64plus-audio-sdl.so'
        'mupen64plus-core/projects/unix/libmupen64plus.so.2.0.0'
        'mupen64plus-input-sdl/projects/unix/mupen64plus-input-sdl.so'
        'mupen64plus-rsp-hle/projects/unix/mupen64plus-rsp-hle.so'
        'mupen64plus-ui-console/projects/unix/mupen64plus'
    )

    if isPlatform "rpi" && ! isPlatform " 64bit"; then
        md_ret_require+=('mupen64plus-audio-omx/projects/unix/mupen64plus-audio-omx.so')
    fi

    if isPlatform "gles"; then
        ! isPlatform "rpi" && md_ret_require+=('mupen64plus-video-glide64mk2/projects/unix/mupen64plus-video-glide64mk2.so')
        if isPlatform "32bit"; then
            md_ret_require+=(
                'mupen64plus-video-gles2n64/projects/unix/mupen64plus-video-n64.so'
                'mupen64plus-video-gles2rice/projects/unix/mupen64plus-video-rice.so'
            )
        fi
    fi

    if isPlatform "gl"; then
        md_ret_require+=(
            'mupen64plus-rsp-z64/projects/unix/mupen64plus-rsp-z64.so'
            'mupen64plus-video-glide64mk2/projects/unix/mupen64plus-video-glide64mk2.so'
        )
        if isPlatform "x86"; then
            md_ret_require+=('mupen64plus-rsp-cxd4/projects/unix/mupen64plus-rsp-cxd4-sse2.so')
        else
            md_ret_require+=('mupen64plus-rsp-cxd4/projects/unix/mupen64plus-rsp-cxd4.so')
        fi
    fi
}

function install_mupen64plus() {
    for source in *; do
        if [[ -f "${source}/projects/unix/Makefile" ]]; then
            local params=()
            isPlatform "rpi" || [[ "${dir}" == "mupen64plus-audio-omx" ]] && params+=("VC=1")
            if isPlatform "mesa" || isPlatform "mali"; then
                params+=("USE_GLES=1")
            fi
            isPlatform "neon" && params+=("NEON=1")
            isPlatform "x11" && params+=("OSD=1" "PIE=1")
            isPlatform "x86" && params+=("SSE=SSE2")
            isPlatform "armv7" && params+=("HOST_CPU=armv7")
            isPlatform "aarch64" && params+=("HOST_CPU=aarch64")
            isPlatform "x86" && params+=("SSE=SSE2")

            make -C "${source}/projects/unix" PREFIX="${md_inst}" "${params[@]}" install
        fi
    done
    cp "${md_build}/GLideN64/ini/GLideN64.custom.ini" "${md_inst}/share/mupen64plus/"
    cp "${md_build}/GLideN64/build/plugin/Release/mupen64plus-video-GLideN64.so" "${md_inst}/lib/mupen64plus/"
    cp "${md_build}/GLideN64_config_version.ini" "${md_inst}/share/mupen64plus/"
    # Remove Default 'InputAutoConfig.ini', 'inputconfigscript' Writes A Clean File
    rm -f "${md_inst}/share/mupen64plus/InputAutoCfg.ini"
}

function configure_mupen64plus() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/n64/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "n64"

        # Copy Hotkey Remapping Start Script
        cp "${md_data}/mupen64plus.sh" "${md_inst}/bin/"
        chmod +x "${md_inst}/bin/mupen64plus.sh"

        # Copy Config Files
        cp -v "${md_inst}/share/mupen64plus/"{*.ini,font.ttf} "${md_conf_root}/n64/${md_id}"
        isPlatform "rpi" && cp -v "${md_inst}/share/mupen64plus/"*.conf "${md_conf_root}/n64/${md_id}"

        local config="${md_conf_root}/n64/${md_id}/mupen64plus.cfg"
        local cmd="${md_inst}/bin/mupen64plus --configdir ${md_conf_root}/n64/${md_id} --datadir ${md_conf_root}/n64/${md_id}"

        # 1) Back Up Existing Mupen64plus Config File
        # 2) Generate A New Mupen64plus Config File
        # 3) Copy Config File To 'rp-dist' And Restore Original Config File
        # 4) Make Changes On The 'rp-dist' File And Create A Default Config File For Reference
        if [[ -f "${config}" ]]; then
            mv "${config}" "${config}.user"
            su "${user}" -c "${cmd}"
            mv "${config}" "${config}.rp-dist"
            mv "${config}.user" "${config}"
            config+=".rp-dist"
        else
            su "${user}" -c "${cmd}"
        fi

        # RPI GLideN64 Settings
        if isPlatform "rpi"; then
            iniConfig " = " "" "${config}"
            # VSync is mandatory for good performance on KMS
            # if isPlatform "kms"; then
            #     if ! grep -q "\[Video-General\]" "${config}"; then
            #         echo "[Video-General]" >> "${config}"
            #     fi
            #     iniSet "VerticalSync" "True"
            # fi
            # Create GlideN64 Section In .cfg
            if ! grep -q "\[Video-GLideN64\]" "${config}"; then
                echo "[Video-GLideN64]" >> "${config}"
            fi
            # Settings Version. Do Not Amend
            iniSet "configVersion" "17"
            # Bilinear Filtering Mode (0=N64 3point, 1=standard)
            iniSet "bilinearMode" "1"
            iniSet "EnableFBEmulation" "True"
            # Use Native Resolution
            iniSet "UseNativeResolutionFactor" "1"
            # Enable Legacy Blending
            iniSet "EnableLegacyBlending" "True"
            # Enable Threaded GL Calls
            iniSet "ThreadedVideo" "True"
            # Swap Frame Buffers On Buffer Update (Most Performant)
            iniSet "BufferSwapMode" "2"
            # Disable Hybrid Upscaling Filter (Requires Better GPU)
            iniSet "EnableHybridFilter" "False"
            # Use fast but less accurate shaders. Can help with low-end GPUs.
            #iniSet "EnableInaccurateTextureCoordinates" "True"

            if isPlatform "rpi"; then
                iniConfig "=" "" "${md_conf_root}/n64/${md_id}/gles2n64.conf"
                setAutoConf mupen64plus_audio 1
                setAutoConf mupen64plus_compatibility_check 1
            fi
        else
            addAutoConf mupen64plus_audio 0
            addAutoConf mupen64plus_compatibility_check 0
        fi

        addAutoConf mupen64plus_hotkeys 1
        addAutoConf mupen64plus_texture_packs 1

        chown -R "${user}:${user}" "${md_conf_root}/n64/${md_id}"
    fi

    local res
    local resolutions=("320x240" "640x480")
    isPlatform "kms" && res="%XRES%x%YRES%"

    if isPlatform "rpi"; then
        if isPlatform "mesa"; then
            addEmulator 0 "${md_id}-GLideN64" "n64" "${md_inst}/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM% ${res} 0 --set Video-GLideN64[UseNativeResolutionFactor]\=1"
            addEmulator 0 "${md_id}-GLideN64-highres" "n64" "${md_inst}/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM% ${res} 0 --set Video-GLideN64[UseNativeResolutionFactor]\=2"
            addEmulator 0 "${md_id}-gles2n64" "n64" "${md_inst}/bin/mupen64plus.sh mupen64plus-video-n64 %ROM%"
            if isPlatform "32bit"; then
                addEmulator 0 "${md_id}-gles2rice" "n64" "${md_inst}/bin/mupen64plus.sh mupen64plus-video-rice %ROM% ${res}"
            fi
        else
            for res in "${resolutions[@]}"; do
                local name=""
                local nativeResFactor=1
                if [[ "${res}" == "640x480" ]]; then
                    name="-highres"
                    nativeResFactor=2
                fi
                addEmulator 0 "${md_id}-GLideN64${name}" "n64" "${md_inst}/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM% ${res} 0 --set Video-GLideN64[UseNativeResolutionFactor]\=$nativeResFactor"
                addEmulator 0 "${md_id}-gles2rice${name}" "n64" "${md_inst}/bin/mupen64plus.sh mupen64plus-video-rice %ROM% ${res}"
            done
            addEmulator 1 "${md_id}-auto" "n64" "${md_inst}/bin/mupen64plus.sh AUTO %ROM%"
        fi
        addEmulator 0 "${md_id}-gles2n64" "n64" "${md_inst}/bin/mupen64plus.sh mupen64plus-video-n64 %ROM%"
    elif isPlatform "mali"; then
        addEmulator 1 "${md_id}-gles2n64" "n64" "${md_inst}/bin/mupen64plus.sh mupen64plus-video-n64 %ROM%"
        addEmulator 0 "${md_id}-GLideN64" "n64" "${md_inst}/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM%"
        addEmulator 0 "${md_id}-glide64" "n64" "${md_inst}/bin/mupen64plus.sh mupen64plus-video-glide64mk2 %ROM%"
        addEmulator 0 "${md_id}-gles2rice" "n64" "${md_inst}/bin/mupen64plus.sh mupen64plus-video-rice %ROM%"
        addEmulator 0 "${md_id}-auto" "n64" "${md_inst}/bin/mupen64plus.sh AUTO %ROM%"
    else
        addEmulator 0 "${md_id}-GLideN64" "n64" "${md_inst}/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM% ${res}"
        addEmulator 1 "${md_id}-glide64" "n64" "${md_inst}/bin/mupen64plus.sh mupen64plus-video-glide64mk2 %ROM% ${res}"
        if isPlatform "x86"; then
            ! isPlatform "kms" && res="640x480"
            addEmulator 0 "${md_id}-GLideN64-LLE" "n64" "${md_inst}/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM% ${res} mupen64plus-rsp-cxd4-sse2"
        fi
    fi

    addSystem "n64"
}
