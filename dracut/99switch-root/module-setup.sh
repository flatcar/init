#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

depends() {
    echo systemd
}

install() {
    inst_simple "${moddir}/override.conf" \
        "${systemdsystemunitdir}/initrd-switch-root.service.d/override.conf"
    inst_simple "${moddir}/initrd-parse-etc-override.conf" \
        "${systemdsystemunitdir}/initrd-parse-etc.service.d/override.conf"
    inst_simple "${moddir}/nocgroup.conf" \
        "/etc/systemd/system.conf.d/nocgroup.conf"
}
