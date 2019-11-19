#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

install() {
    inst_rules "$moddir/65-start-root.rules"

    rm -f "$initdir/usr/lib/systemd/system/systemd-tmpfiles-setup.service"
    rm -f "$initdir/usr/lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup.service"
}
