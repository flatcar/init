#!/bin/bash
set -e
cmdline=( $(</proc/cmdline) )
cmdline_arg() {
    local name="$1" value="$2"
    for arg in "${cmdline[@]}"; do
        if [[ "${arg%%=*}" == "${name}" ]]; then
            value="${arg#*=}"
        fi
    done
    echo "${value}"
}

# First, check for the cmdline option in case it was set.
RANDOMIZE_DISK_GUID=$(cmdline_arg flatcar.randomize_disk_guid)

# But we are no longer detecting the non-randomized UUID in GRUB,
# so set the base guid here if the cmdline was not set.
BASE_GUID="00000000-0000-0000-0000-000000000001"
if [[ -z "$RANDOMIZE_DISK_GUID" ]]; then
    RANDOMIZE_DISK_GUID="${BASE_GUID}"
fi

# Check that the by-diskuuid path exists. If it doesn't, this script is
# useless, so highlight that by exiting with a failure code
DEVPATH="/dev/disk/by-diskuuid"
if [[ ! -e ${DEVPATH} ]]; then
    echo "${DEVPATH} does not exist. Bailing out"
    exit 1
fi

# Verify the device actually exists before trying to touch it
DEVICE="${DEVPATH}/${RANDOMIZE_DISK_GUID}"
if [[ -e "${DEVICE}" ]]; then
    /usr/bin/cgpt repair ${DEVICE}
    /usr/sbin/sgdisk --disk-guid=R ${DEVICE}
    /usr/bin/udevadm settle || echo "udevadm settle failed"
fi
