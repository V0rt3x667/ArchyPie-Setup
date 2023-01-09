#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="samba"
rp_module_desc="Configure Samba ROM Shares"
rp_module_section="config"

function depends_samba() {
    getDepends samba
}

function remove_share_samba() {
    local name="$1"
    [[ -z "$name" || ! -f /etc/samba/smb.conf ]] && return
    sed -i "/^\[$name\]/,/^force user/d" /etc/samba/smb.conf
}

function add_share_samba() {
    local name="$1"
    local path="$2"
    [[ -z "$name" || -z "$path" ]] && return
    remove_share_samba "$name"
    cat >>/etc/samba/smb.conf <<_EOF_
[$1]
comment = $name
path = "$path"
writeable = yes
guest ok = yes
create mask = 0644
directory mask = 0755
force user = ${user}
_EOF_
}

function restart_samba() {
  systemctl restart smb
}

function install_shares_samba() {
    [[ -f /etc/samba/smb.conf ]] && cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
    add_share_samba "roms" "$romdir"
    add_share_samba "bios" "$home/ArchyPie/BIOS"
    add_share_samba "configs" "$configdir"
    isPlatform "rpi" && add_share_samba "splashscreens" "$datadir/splashscreens"
    restart_samba
}

function remove_shares_samba() {
    local names=(
        'bios'
        'configs'
        'roms'
    )
    isPlatform "rpi" && names+=('splashscreens')

    for name in "${names[@]}"; do
        remove_share_samba "$name"
    done
    restart_samba
}

function gui_samba() {
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local options=(
            1 "Install ArchyPie Samba Shares"
            2 "Remove ArchyPie Samba Shares"
            3 "Manually Edit /etc/samba/smb.conf"
            4 "Restart Samba Service"
            5 "Remove Samba & Configuration"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "${choice}" ]]; then
            case "${choice}" in
                1)
                    rp_callModule "$md_id" depends
                    rp_callModule "$md_id" install_shares
                    printMsgs "dialog" "Installed and Enabled Shares"
                    ;;
                2)
                    rp_callModule "$md_id" remove_shares
                    printMsgs "dialog" "Removed Shares"
                    ;;
                3)
                    editFile /etc/samba/smb.conf
                    ;;
                4)
                    rp_callModule "$md_id" restart
                    ;;
                5)
                    rp_callModule "$md_id" depends remove
                    printMsgs "dialog" "Removed Samba Service"
                    ;;
            esac
        else
            break
        fi
    done
}
