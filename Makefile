# A simple install Makefile
DESTDIR :=

all:
	@echo "Nothing to build! Try make install"

test:
	$(MAKE) -C tests test

test-root:
	$(MAKE) -C tests test-root

install:
	install -m 755 -d \
		$(DESTDIR)/lib/udev/rules.d \
		$(DESTDIR)/usr/bin \
		$(DESTDIR)/usr/sbin \
		$(DESTDIR)/usr/lib/flatcar \
		$(DESTDIR)/usr/lib/systemd/system \
		$(DESTDIR)/usr/lib/systemd/network \
		$(DESTDIR)/usr/lib/systemd/system-generators \
		$(DESTDIR)/usr/lib/tmpfiles.d \
		$(DESTDIR)/etc/env.d \
		$(DESTDIR)/usr/share/ssh \
		$(DESTDIR)/usr/lib/modules-load.d
	install -m 755 bin/* $(DESTDIR)/usr/bin
	install -m 755 sbin/* $(DESTDIR)/usr/sbin
	ln -sf flatcar-install $(DESTDIR)/usr/bin/coreos-install
	install -m 755 scripts/* $(DESTDIR)/usr/lib/flatcar
	install -m 644 udev/rules.d/* $(DESTDIR)/lib/udev/rules.d
	install -m 755 udev/bin/* $(DESTDIR)/lib/udev
	install -m 644 configs/editor.sh $(DESTDIR)/etc/env.d/99editor
	install -m 644 configs/modules-load.d/* $(DESTDIR)/usr/lib/modules-load.d/
	install -m 600 configs/sshd_config $(DESTDIR)/usr/share/ssh/
	install -m 644 configs/ssh_config $(DESTDIR)/usr/share/ssh/
	install -m 644 configs/tmpfiles.d/* $(DESTDIR)/usr/lib/tmpfiles.d/
	cp -a systemd/* $(DESTDIR)/usr/lib/systemd/
	chmod 755 $(DESTDIR)/usr/lib/systemd/system-generators/*
	ln -sf ../run/issue $(DESTDIR)/etc/issue
	ln -sf flatcar $(DESTDIR)/usr/lib/coreos
	ln -sf flatcar $(DESTDIR)/usr/share/coreos

install-usr: install

.PHONY: all test test-root install-usr install
