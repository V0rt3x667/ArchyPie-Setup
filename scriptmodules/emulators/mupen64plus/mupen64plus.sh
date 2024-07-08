#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

AUDIO_PLUGIN="mupen64plus-audio-sdl"
VIDEO_PLUGIN="${1}"
ROM="${2}"
[[ "${3}" != 0 ]] && RES="${3}"
[[ "${4}" -ne 0 ]] && RSP_PLUGIN="${4}"
PARAMS="${@:5}"
[[ -n "${RES}" ]] && RES="--resolution ${RES}"
[[ -z "${RSP_PLUGIN}" ]] && RSP_PLUGIN="mupen64plus-rsp-hle"
WINDOW_MODE="--fullscreen ${RES}"

rootdir="/opt/archypie"
configdir="${rootdir}/configs"
config="${configdir}/n64/mupen64plus/mupen64plus.cfg"
inputconfig="${configdir}/n64/mupen64plus/InputAutoCfg.ini"
datadir="${HOME}/ArchyPie"
romdir="${datadir}/roms"

source "${rootdir}/lib/inifuncs.sh"

# Arg 1: Hotkey Name, Arg 2: Device Number, Arg 3: Retroarch Auto Config File
function getBind() {
    local key="${1}"
    local m64p_hotkey="J${2}"
    local file="${3}"

    iniConfig " = " "" "${file}"

    # Search Hotkey Enable Button
    local hotkey
    local input_type
    local i=0
    for hotkey in input_enable_hotkey "${key}"; do
        for input_type in "_btn" "_axis"; do
            iniGet "${hotkey}${input_type}"
            ini_value="${ini_value// /}"
            if [[ -n "${ini_value}" ]]; then
                ini_value="${ini_value//\"/}"
                case "${input_type}" in
                    _axis)
                        m64p_hotkey+="A${ini_value:1}${ini_value:0:1}"
                        ;;
                    _btn)
                        # If 'ini_value' Contains 'h' It Should Be A Hat Device
                        if [[ "${ini_value}" == *h* ]]; then
                            local dir="${ini_value:2}"
                            ini_value="${ini_value:1}"
                            case ${dir} in
                                up)
                                    dir="1"
                                    ;;
                                right)
                                    dir="2"
                                    ;;
                                down)
                                    dir="4"
                                    ;;
                                left)
                                    dir="8"
                                    ;;
                            esac
                            m64p_hotkey+="H${ini_value}V${dir}"
                        else
                            [[ "${atebitdo_hack}" -eq 1 && "${ini_value}" -ge 11 ]] && ((ini_value-=11))
                            m64p_hotkey+="B${ini_value}"
                        fi
                        ;;
                esac
            fi
        done
        [[ "${i}" -eq 0 ]] && m64p_hotkey+="/"
        ((i++))
    done
    echo "${m64p_hotkey}"
}

function remap() {
    local device
    local devices
    local device_num

    # Get Lists Of All Present JS Device Numbers And Device Names
    # Get Device Count
    while read -r device; do
        device_num="${device##*/js}"
        devices[${device_num}]=$(</sys/class/input/js${device_num}/device/name)
    done < <(find /dev/input -name "js*")

    # Read Retroarch Auto Config File And Use Config For 'mupen64plus.cfg'
    local file
    local bind
    local hotkeys_rp=("input_exit_emulator" "input_load_state" "input_save_state")
    local hotkeys_m64p=("Joy Mapping Stop" "Joy Mapping Load State" "Joy Mapping Save State")
    local i
    local j

    iniConfig " = " "" "${config}"
    if ! grep -q "\[CoreEvents\]" "${config}"; then
        echo "[CoreEvents]" >> "${config}"
        echo "Version = 1" >> "${config}"
    fi

    local atebitdo_hack
    for i in {0..2}; do
        bind=""
        for device_num in "${!devices[@]}"; do
            # Get Name Of Retroarch Auto Config File
            file=$(grep -lF "\"${devices[${device_num}]}\"" "${configdir}/all/retroarch-joypads/"*.cfg)
            atebitdo_hack=0
            [[ "${file}" == *8Bitdo* ]] && getAutoConf "8bitdo_hack" && atebitdo_hack=1
            if [[ -f "${file}" ]]; then
                if [[ -n "${bind}" && "${bind}" != *, ]]; then
                    bind+=","
                fi
                bind+=$(getBind "${hotkeys_rp[${i}]}" "${device_num}" "${file}")
            fi
        done
        # Write Hotkey To 'mupen64plus.cfg'
        iniConfig " = " "\"" "${config}"
        iniSet "${hotkeys_m64p[${i}]}" "${bind}"
    done
}

function testCompatibility() {
    # Fallback For glesn64 & rice Plugins
    # Some Roms Lead To A Black Screen Of Death
    local game

    # These Games Need RSP-LLE
    local blacklist=(
        'body'
        'naboo'
    )

    # These Games Do Not Run With gles2n64
    local glesn64_blacklist=(
        'beetle'
        'gauntlet'
        'instinct'
        'kazooie'
        'paper'
        'rogue'
        'squadron'
        'tooie'
        'zelda'
    )

    # These Games Do Not Run With rice
    local glesn64rice_blacklist=(
        'gauntlet'
        'infernal'
        'rogue'
        'squadron'
        'yoshi'
    )

    # These Games Have Massive Glitches If Legacy Blending Is Enabled
    local GLideN64LegacyBlending_blacklist=(
        'beetle'
        'bomberman'
        'donkey'
        'empire'
        'infernal'
        'zelda'
    )

    local GLideN64NativeResolution_blacklist=(
        'majora'
    )

    # These Games Have Major Problems With GLideN64
    local gliden64_blacklist=(
        'conker'
        'zelda'
    )

    for game in "${blacklist[@]}"; do
        if [[ "${ROM,,}" == *"${game}"* ]]; then
            exit
        fi
    done

    case "${VIDEO_PLUGIN}" in
        "mupen64plus-video-GLideN64")
            if ! grep -q "\[Video-GLideN64\]" "${config}"; then
                echo "[Video-GLideN64]" >> "${config}"
            fi
            iniConfig " = " "" "${config}"
            # Settings Version, Don't Touch It
            local config_version="20"
            if [[ -f "${configdir}/n64/mupen64plus/GLideN64_config_version.ini" ]]; then
                config_version=$(<"${configdir}/n64/mupen64plus/GLideN64_config_version.ini")
            fi
            iniSet "configVersion" "${config_version}"
            # Set Native Resolution Factor Of 1
            iniSet "UseNativeResolutionFactor" "1"
            for game in "${GLideN64NativeResolution_blacklist[@]}"; do
                if [[ "${ROM,,}" == *"${game}"* ]]; then
                    iniSet "UseNativeResolutionFactor" "0"
                    break
                fi
            done
            # Disable LegacyBlending If Necessary
            iniSet "EnableLegacyBlending" "True"
            for game in "${GLideN64LegacyBlending_blacklist[@]}"; do
                if [[ "${ROM,,}" == *"${game}"* ]]; then
                    iniSet "EnableLegacyBlending" "False"
                    break
                fi
            done
            for game in "${gliden64_blacklist[@]}"; do
                if [[ "${ROM,,}" == *"${game}"* ]]; then
                    VIDEO_PLUGIN="mupen64plus-video-rice"
                fi
            done
            ;;
        "mupen64plus-video-n64"|"mupen64plus-video-rice")
            for game in "${glesn64_blacklist[@]}"; do
                if [[ "${ROM,,}" == *"${game}"* ]]; then
                    VIDEO_PLUGIN="mupen64plus-video-rice"
                fi
            done
            for game in "${glesn64rice_blacklist[@]}"; do
                if [[ "${ROM,,}" == *"${game}"* ]]; then
                    VIDEO_PLUGIN="mupen64plus-video-GLideN64"
                fi
            done
            ;;
    esac

    # Fix Audio-SDL Crackle
    iniConfig " = " "\"" "${config}"
    # Create Section If Necessary
    if ! grep -q "\[Audio-SDL\]" "${config}"; then
        echo "[Audio-SDL]" >> "${config}"
        echo "Version = 1" >> "${config}"
    fi
    iniSet "RESAMPLE" "src-sinc-fastest"
}

function useTexturePacks() {
    # Video-GLideN64
    if ! grep -q "\[Video-GLideN64\]" "${config}"; then
        echo "[Video-GLideN64]" >> "${config}"
    fi
    iniConfig " = " "" "${config}"
    # Settings Version, Don't Touch It
    local config_version="17"
    if [[ -f "${configdir}/n64/mupen64plus/GLideN64_config_version.ini" ]]; then
        config_version=$(<"${configdir}/n64/mupen64plus/GLideN64_config_version.ini")
    fi
    iniSet "configVersion" "${config_version}"
    iniSet "txHiresEnable" "True"

    # Video-Rice
    if ! grep -q "\[Video-Rice\]" "${config}"; then
        echo "[Video-Rice]" >> "${config}"
    fi
    iniSet "LoadHiResTextures" "True"
}

function autoset() {
    VIDEO_PLUGIN="mupen64plus-video-GLideN64"
    RES="--resolution 320x240"
    PARAMS="--set Video-GLideN64[UseNativeResolutionFactor]=1"

    local game
    # These Games Run Fine And Look Better With 640x480
    local highres=(
        '1080'
        'bomberman'
        'dark'
        'diddy'
        'harvest'
        'party'
        'pokemon'
        'starcraft'
        'wipeout'
        'worms'
        'yoshi'
    )

    for game in "${highres[@]}"; do
        if [[ "${ROM,,}" == *"${game}"* ]]; then
            RES="--resolution 640x480"
            PARAMS="--set Video-GLideN64[UseNativeResolutionFactor]=2"
            break
        fi
    done

    # These Games Have No Glitches & Run Faster With gles2n64
    local gles2n64=(
        'kart'
        'wave'
    )

    for game in "${gles2n64[@]}"; do
        if [[ "${ROM,,}" == *"${game}"* ]]; then
            VIDEO_PLUGIN="mupen64plus-video-n64"
            break
        fi
    done

    # These Games Have No Glitches Or Run Faster With Rice
    local gles2rice=(
        '1080'
        'conker'
        'darkness'
        'diddy'
        'tooie'
    )

    for game in "${gles2rice[@]}"; do
        if [[ "${ROM,,}" == *"${game}"* ]]; then
            VIDEO_PLUGIN="mupen64plus-video-rice"
            break
        fi
    done
}

if ! grep -q "\[Core\]" "${config}"; then
    echo "[Core]" >> "${config}"
    echo "Version = 1.010000" >> "${config}"
fi
iniConfig " = " "\"" "${config}"

function setPath() {
    iniSet "ScreenshotPath" "${romdir}/n64"
    iniSet "SaveStatePath"  "${romdir}/n64"
    iniSet "SaveSRAMPath"   "${romdir}/n64"
}

# Add Default Keyboard Configuration If 'InputAutoCfg.ini' Is Missing
if [[ ! -f "${inputconfig}" ]]; then
    cat > "${inputconfig}" << _EOF_
; InputAutoCfg.ini for Mupen64Plus SDL Input plugin

; Keyboard_START
[Keyboard]
plugged = True
plugin = 2
mouse = False
DPad R = key(100)
DPad L = key(97)
DPad D = key(115)
DPad U = key(119)
Start = key(13)
Z Trig = key(122)
B Button = key(306)
A Button = key(304)
C Button R = key(108)
C Button L = key(106)
C Button D = key(107)
C Button U = key(105)
R Trig = key(99)
L Trig = key(120)
Mempak switch = key(44)
Rumblepak switch = key(46)
X Axis = key(276,275)
Y Axis = key(273,274)
; Keyboard_END

_EOF_
fi

getAutoConf mupen64plus_savepath && setPath
getAutoConf mupen64plus_hotkeys && remap
[[ "${VIDEO_PLUGIN}" == "AUTO" ]] && autoset
getAutoConf mupen64plus_compatibility_check && testCompatibility
getAutoConf mupen64plus_texture_packs && useTexturePacks


# If A Raspberry Pi (<5) Device Is Used Lower Resolution To 320x240 & Enable SDL Scaling Mode 1
if [[ -f /proc/device-tree/compatible ]]; then
    if tr -d '\0' < /proc/device-tree/compatible | grep -Eq raspberrypi,[1-4]; then
        WINDOW_MODE="--windowed ${RES}"
        SDL_VIDEO_RPI_SCALE_MODE=1
    fi
fi

SDL_AUDIODRIVER=${SDL_AUDIODRIVER} SDL_VIDEO_RPI_SCALE_MODE=${SDL_VIDEO_RPI_SCALE_MODE} "${rootdir}/emulators/mupen64plus/bin/mupen64plus" --noosd ${PARAMS} ${WINDOW_MODE} --rsp ${RSP_PLUGIN}.so --gfx ${VIDEO_PLUGIN}.so --audio ${AUDIO_PLUGIN}.so --configdir "${configdir}/n64/mupen64plus" --datadir "${configdir}/n64/mupen64plus" "${ROM}"
