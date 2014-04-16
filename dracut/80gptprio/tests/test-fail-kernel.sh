#!/bin/sh

. ./include.sh
. ./fixtures.sh

_rebooted=0
systemctl() {
    echo "systemctl $@"
    assert [ "$*" = "--no-block reboot" ]
    _rebooted=1
}

create_root
. ../parse-gptprio.sh
. ../pre-mount-gptprio.sh
assert [ $_mounted -eq 1 ]
assert [ "$_mount_args" = "-o ro /dev/disk/by-partuuid/7130c94a-213a-4e5a-8e26-6cce9662f132 ./mnt" ]
cleanup_root