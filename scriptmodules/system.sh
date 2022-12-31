#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

function setup_env() {
    __ERRMSGS=()
    __INFMSGS=()

    # Test for the pacman command, if not found we need to fail.
    [[ ! -f /usr/bin/pacman ]] && fatalError "Unsupported OS: No Pacman Command Found!"

    test_chroot

    get_platform
    get_os_version
    get_archypie_depends

    conf_memory_vars
    conf_binary_vars
    conf_build_vars

    if [[ -z "$__nodialog" ]]; then
        __nodialog=0
    fi
}

function test_chroot() {
    # Test if we are in a chroot
    if [[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]]; then
        [[ -z "$QEMU_CPU" && -n "$__qemu_cpu" ]] && export QEMU_CPU=$__qemu_cpu
        __chroot=1
    # Detect the usage of systemd-nspawn
    elif [[ -n "$(systemd-detect-virt)" && "$(systemd-detect-virt)" == "systemd-nspawn" ]]; then
        __chroot=1
    else
        __chroot=0
    fi
}

function conf_memory_vars() {
    __memory_total_kb=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
    __memory_total=$(( __memory_total_kb / 1024 ))
    if grep -q "^MemAvailable:" /proc/meminfo; then
        __memory_avail_kb=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)
    else
        local mem_free=$(awk '/^MemFree:/{print $2}' /proc/meminfo)
        local mem_cached=$(awk '/^Cached:/{print $2}' /proc/meminfo)
        local mem_buffers=$(awk '/^Buffers:/{print $2}' /proc/meminfo)
        __memory_avail_kb=$((mem_free + mem_cached + mem_buffers))
    fi
    __memory_avail=$(( __memory_avail_kb / 1024 ))
}

function conf_binary_vars() {
    [[ -z "$__has_binaries" ]] && __has_binaries=0

    # Set location of binary downloads
    __binary_host="files.retropie.org.uk"
    __binary_base_url="https://$__binary_host/binaries"

    # Code might be used at a future date
    # __binary_path="$__os_codename/$__platform"
    # isPlatform "kms" && __binary_path+="/kms"
    # __binary_url="$__binary_base_url/$__binary_path"

    __archive_url="https://files.retropie.org.uk/archives"
    __arpie_url="https://github.com/V0rt3x667/ArchyPie-Resources/raw"

    # Set the GPG key used by ArchyPie
    __gpg_retropie_key="retropieproject@gmail.com"

    # If __gpg_signing_key is not set, set to __gpg_retropie_key
    [[ ! -v __gpg_signing_key ]] && __gpg_signing_key="$__gpg_retropie_key"

    # If the RetroPie public key is not installed, install it.
    if ! gpg --list-keys "$__gpg_retropie_key" &>/dev/null; then
        gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys DC9D77FF8208FFC51D8F50CCF1B030906A3B0D31
    fi
}

function conf_build_vars() {
    __gcc_version=$(gcc -dumpversion)

    # Calculate build concurrency based on cores and available memory
    __jobs=1
    local unit=512
    isPlatform "64bit" && unit=$(($unit + 256))
    if [[ "$(nproc)" -gt 1 ]]; then
        local nproc="$(nproc)"
        # Max one thread per unit (MB) of RAM
        local max_jobs=$(($__memory_avail / $unit))
        if [[ "$max_jobs" -gt 0 ]]; then
            if [[ "$max_jobs" -lt "$nproc" ]]; then
                __jobs="$max_jobs"
            else
                __jobs="$nproc"
            fi
        fi
    fi
    __default_makeflags="-j${__jobs}"

    # Set our default GCC optimisation level
    if [[ -z "$__opt_flags" ]]; then
        __opt_flags="$__default_opt_flags"
    fi

    # Set default CPU flags
    [[ -z "$__cpu_flags" ]] && __cpu_flags="$__default_cpu_flags"

    # If __default_cxxflags is empty, use our __default_cflags
    [[ -z "$__default_cxxflags" ]] && __default_cxxflags="$__default_cflags"

    # Add our CPU and optimisation flags
    __default_cflags+=" $__cpu_flags $__opt_flags"
    __default_cxxflags+=" $__cpu_flags $__opt_flags"
    __default_asflags+=" $__cpu_flags"

    # If not overridden by user, configure our compiler flags
    [[ -z "$__cflags" ]] && __cflags="$__default_cflags"
    [[ -z "$__cxxflags" ]] && __cxxflags="$__default_cxxflags"
    [[ -z "$__asflags" ]] && __asflags="$__default_asflags"
    [[ -z "$__makeflags" ]] && __makeflags="$__default_makeflags"
    [[ -z "$__ldflags" ]] && __ldflags="$__default_ldflags"

    # Export our compiler flags so all child processes can see them
    export CFLAGS="$__cflags"
    export CXXFLAGS="$__cxxflags"
    export ASFLAGS="$__asflags"
    export MAKEFLAGS="$__makeflags"
    export LDFLAGS="$__ldflags"

    # If using distcc, add /usr/lib/distcc to PATH/MAKEFLAGS
    if [[ -n "$DISTCC_HOSTS" ]]; then
        PATH="/usr/lib/distcc:$PATH"
        MAKEFLAGS+=" PATH=$PATH"
    fi

    # If __use_ccache is set, then add ccache to PATH/MAKEFLAGS
    if [[ "$__use_ccache" -eq 1 ]]; then
        PATH="/usr/lib/ccache:$PATH"
        MAKEFLAGS+=" PATH=$PATH"
    fi
}

function get_os_version() {
    # Make sure lsb_release is installed
    getDepends lsb-release

    # Get OS Distributor ID and Release
    __os_desc=$(lsb_release -sir)

    # Code might be used at a future date
    # We provide binaries for RPI
    # if isPlatform "rpi" && isPlatform "32bit"; then
    #    # only set __has_binaries if not already set
    #    [[ -z "$__has_binaries" ]] && __has_binaries=1
    # fi

    # Configure Raspberry Pi graphics stack
    isPlatform "rpi" && get_rpi_video
}

function get_archypie_depends() {
    local basedev
    local depends=(
        'ca-certificates'
        'curl'
        'dialog'
        'git'
        'gnupg'
        'python'
        'unzip'
        'xmlstarlet'
    )
    basedev="$(pacman -Sg base-devel | cut -d ' ' -f2)" && depends+=(${basedev[@]}) # Do not quote

    [[ -n "$DISTCC_HOSTS" ]] && depends+=('distcc')

    [[ "$__use_ccache" -eq 1 ]] && depends+=('ccache')

    if ! getDepends "${depends[@]}"; then
        fatalError "Unable to install packages required by $0 - ${md_ret_errors[@]}"
    fi
}

function get_rpi_video() {
    local pkgconfig="/opt/vc/lib/pkgconfig"

    if [[ -z "$__has_kms" ]]; then
        # In chroot, use KMS by default for rpi4 target
        [[ "$__chroot" -eq 1 ]] && isPlatform "rpi4" && __has_kms=1
        # Detect driver via inserted module/platform driver setup
        [[ -d "/sys/module/vc4" ]] && __has_kms=1
    fi

    if [[ "$__has_kms" -eq 1 ]]; then
        __platform_flags+=('mesa' 'kms')
        if [[ -z "$__has_dispmanx" ]]; then
            # In a chroot, unless __has_dispmanx is set, default to fkms (adding dispmanx flag)
            [[ "$__chroot" -eq 1 ]] && __has_dispmanx=1
            # If running fkms driver, add dispmanx flag
            [[ "$(ls -A /sys/bus/platform/drivers/vc4_firmware_kms/*.firmwarekms 2>/dev/null)" ]] && __has_dispmanx=1
        fi
        [[ "$__has_dispmanx" -eq 1 ]] && __platform_flags+=('dispmanx')
    else
        __platform_flags+=('videocore' 'dispmanx')
    fi

    # Set pkgconfig path for vendor libraries
    export PKG_CONFIG_PATH="$pkgconfig"
}

function get_platform() {
    local architecture="$(uname --machine)"
    if [[ -z "$__platform" ]]; then
        case "$(sed -n '/^Hardware/s/^.*: \(.*\)/\1/p' < /proc/cpuinfo)" in
            BCM*)
                # Calculated based on information from https://github.com/AndrewFromMelbourne/raspberry_pi_revision
                local rev="0x$(sed -n '/^Revision/s/^.*: \(.*\)/\1/p' < /proc/cpuinfo)"
                # If bit 23 is set, get the CPU from bits 12-15
                local cpu=$((($rev >> 12) & 15))
                case $cpu in
                    1)
                        __platform="rpi2"
                        ;;
                    2)
                        __platform="rpi3"
                        ;;
                    3)
                        __platform="rpi4"
                        ;;
                esac
                ;;
            *ODROIDC)
                __platform="odroid-c1"
                ;;
            *ODROID-C2)
                __platform="odroid-c2"
                ;;
            "Freescale i.MX6 Quad/DualLite (Device Tree)")
                __platform="imx6"
                ;;
            *ODROID-XU[34])
                __platform="odroid-xu"
                ;;
            "Allwinner sun8i Family")
                __platform="armv7-mali"
                ;;
            *)
                # Jetsons can be identified by device tree or soc0/family (depending on the L4T version used),
                # refer to the nv.sh script in the L4T DTS for a similar implementation
                if [[ -e "/proc/device-tree/compatible" ]]; then
                    case "$(tr -d '\0' < /proc/device-tree/compatible)" in
                        *tegra186*)
                            __platform="tegra-x2"
                            ;;
                        *tegra210*)
                            __platform="tegra-x1"
                            ;;
                        *tegra194*)
                            __platform="xavier"
                            ;;
                        *rockpro64*)
                            __platform="rockpro64"
                            ;;
                    esac
                elif [[ -e "/sys/devices/soc0/family" ]]; then
                    case "$(tr -d '\0' < /sys/devices/soc0/family)" in
                        *tegra30*)
                            __platform="tegra-3"
                            ;;
                        *tegra114*)
                            __platform="tegra-4"
                            ;;
                        *tegra124*)
                            __platform="tegra-k1-32"
                            ;;
                        *tegra132*)
                            __platform="tegra-k1-64"
                            ;;
                        *tegra210*)
                            __platform="tegra-x1"
                            ;;
                    esac
                else
                    __platform="$architecture"
                fi
                ;;
        esac
    fi

    # Check if we wish to target KMS for platform
    if [[ -z "$__has_kms" ]]; then
        iniConfig " = " '"' "$configdir/all/archypie.cfg"
        iniGet "force_kms"
        [[ "$ini_value" == 1 ]] && __has_kms=1
        [[ "$ini_value" == 0 ]] && __has_kms=0
    fi

    set_platform_defaults

    # If we have a function for the platform call it, otherwise use the default "native" one.
    if fnExists "platform_${__platform}"; then
        "platform_${__platform}"
    else
        platform_native
    fi
}

function set_platform_defaults() {
    __default_opt_flags="-O3"

    # Add platform name and 32bit/64bit to platform flags
    __platform_flags=("$__platform" "$(getconf LONG_BIT)bit")
    __platform_arch=$(uname -m)
}

function cpu_armv7() {
    local cpu="$1"
    if [[ -n "$cpu" ]]; then
        __default_cpu_flags="-mcpu=$cpu -mfpu=neon-vfpv4"
    else
        __default_cpu_flags="-march=armv7-a -mfpu=neon-vfpv4"
        cpu="cortex-a7"
    fi
    __platform_flags+=('arm' 'armv7' 'neon')
    __qemu_cpu="$cpu"
}

function cpu_armv8() {
    local cpu="$1"
    __default_cpu_flags="-mcpu=$cpu"
    if isPlatform "32bit"; then
        __default_cpu_flags+=" -mfpu=neon-fp-armv8"
        __platform_flags+=('arm' 'armv8' 'neon')
    else
        __platform_flags+=('aarch64')
    fi
    __qemu_cpu="$cpu"
}

function cpu_arm_state() {
    if isPlatform "32bit"; then
        __default_cpu_flags+=" -marm"
    fi
}

function platform_conf_glext() {
   # Required for mali-fbdev headers to define GL functions
    __default_cflags="-DGL_GLEXT_PROTOTYPES"
}

function platform_rpi2() {
    cpu_armv7 "cortex-a7"
    __platform_flags+=('rpi' 'gles')
}

function platform_rockpro64() {
    cpu_armv8 "cortex-a53"
    __platform_flags+=('gles' 'kms')
}

function platform_rpi3() {
    cpu_armv8 "cortex-a53"
    __platform_flags+=('rpi' 'gles')
}

function platform_rpi4() {
    cpu_armv8 "cortex-a72"
    __platform_flags+=('rpi' 'gles' 'gles3' 'gles31')
}

function platform_odroid-c1() {
    cpu_armv7 "cortex-a5"
    cpu_arm_state
    __platform_flags+=('mali' 'gles')
}

function platform_odroid-c2() {
    cpu_armv8 "cortex-a72"
    cpu_arm_state
    __platform_flags+=('mali' 'gles')
}

function platform_odroid-xu() {
    cpu_armv7 "cortex-a7"
    cpu_arm_state
    platform_conf_glext
    __platform_flags+=('mali' 'gles')
}

function platform_tegra-x1() {
    cpu_armv8 "cortex-a57+crypto"
    __platform_flags+=('x11' 'gl')
}

function platform_tegra-x2() {
    cpu_armv8 "cortex-a57+crypto"
    __platform_flags+=('x11' 'gl')
}

function platform_xavier() {
    cpu_armv8 "native"
    __platform_flags+=('x11' 'gl')
}

function platform_tegra-3() {
    cpu_armv7 "cortex-a9"
    __platform_flags+=('x11' 'gles')
}

function platform_tegra-4() {
    cpu_armv7 "cortex-a15"
    __platform_flags+=('x11' 'gles')
}

function platform_tegra-k1-32() {
    cpu_armv7 "cortex-a15"
    __platform_flags+=('x11' 'gl')
}

function platform_tegra-k1-64() {
    cpu_armv8 "native"
    __platform_flags+=('x11' 'gl')
}

function platform_native() {
    local flags=(
        '-march=native' \
        '-mtune=native' \
        '-pipe' \
        '-fno-plt' \
        '-fexceptions' \
        '-Wp,-D_FORTIFY_SOURCE=2' \
        '-Wformat' \
        '-Werror=format-security' \
        '-fstack-clash-protection' \
        '-fcf-protection'
    )
    __default_cpu_flags="${flags[*]}"
    __default_cxxflags+=" -Wp,-D_GLIBCXX_ASSERTIONS"
    __default_ldflags="-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now"
    __platform_flags+=('gl')

    for file in /run/user/1000/wayland-*; do
        if [[ -f "$file" ]]; then
            __platform_flags+=('wayland')
        fi
        if [[ "$__has_kms" -eq 1 ]]; then
            __platform_flags+=('kms')
        fi
        if [[ -z "$file" && "$__has_kms" -eq 0 ]]; then
            __platform_flags+=('x11')
        fi
    done
    # Add x86 platform flag for x86/x86_64 architectures.
    [[ "$__platform_arch" =~ (i386|i686|x86_64) ]] && __platform_flags+=('x86')
}

function platform_armv7-mali() {
    cpu_armv7
    __platform_flags+=('mali' 'gles')
}

function platform_imx6() {
    cpu_armv7 "cortex-a9"
}
