#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-flycast"
rp_module_desc="Sega Dreamcast & Naomi Atomiswave Libretro Core"
rp_module_help="Dreamcast ROM Extensions: .cdi .gdi .chd .m3u, Naomi Atomiswave ROM Extension: .zip\n\nCopy your Dreamcast/Naomi roms to $romdir/dreamcast\n\nCopy the required Dreamcast BIOS files dc_boot.bin and dc_flash.bin to $biosdir/dc\n\nCopy the required Naomi/Atomiswave BIOS files naomi.zip and awbios.zip to $biosdir/dc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/flycast/master/LICENSE"
rp_module_repo="git https://github.com/flyinghead/flycast master"
rp_module_section="opt"
rp_module_flags=""

function depends_lr-flycast() {
    local depends=(zlib)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    isPlatform "mesa" && depends+=(libgles2-mesa-dev)
    getDepends "${depends[@]}"
}

function sources_lr-flycast() {
    gitPullOrClone
    # don't override our C/CXXFLAGS and set LDFLAGS to CFLAGS to avoid warnings on linking
    applyPatch "$md_data/01_flags_fix.diff"
}

function build_lr-flycast() {
    local params=("HAVE_LTCG=0")
    local add_flags=()
    if isPlatform "gles"; then
        if isPlatform "rpi"; then
            params+=(
                "GLES=1"
                "GL_LIB=-L/opt/vc/lib -lbrcmGLESv2")
            add_flags+=("-I/opt/vc/include -DTARGET_NO_STENCIL -DLOW_END")
        else
            params+=("FORCE_GLES=1")
        fi
        if isPlatform "gles3"; then
            params+=("HAVE_GL3=1")
        else
            params+=("HAVE_GL3=0")
        fi
    fi
    isPlatform "aarch64" && params+=("WITH_DYNAREC=arm64" "HOST_CPU_FLAGS=-DTARGET_LINUX_ARMv8")
    isPlatform "arm" && params+=("WITH_DYNAREC=arm")
    ! isPlatform "x86" && params+=("HAVE_GENERIC_JIT=0" "HAVE_VULKAN=0")
    make "${params[@]}" clean
    CFLAGS+=" ${add_flags[@]}" make "${params[@]}"
    md_ret_require="$md_build/flycast_libretro.so"
}

function install_lr-flycast() {
    md_ret_files=(
        'flycast_libretro.so'
        'LICENSE'
    )
}

function configure_lr-flycast() {
    local sys
    local systems=(dreamcast arcade)
    local def
    for sys in "${systems[@]}"; do
        def=0
        if isPlatform "kms" && [[ "$sys" == "dreamcast" ]]; then
            def=1
        fi
        # segfaults on the rpi without redirecting stdin from </dev/null
        addEmulator $def "$md_id" "$sys" "$md_inst/flycast_libretro.so </dev/null"
        addSystem "$sys"
    done

    [[ "$md_mode" == "remove" ]] && return

    local params=()
    # system-specific
    if isPlatform "gl"; then
        params+=("video_shared_context" "true")
    fi

    for sys in "${systems[@]}"; do
        mkRomDir "$sys"
        defaultRAConfig "$sys" "${params[@]}"
    done

    mkUserDir "$biosdir/dc"
}
