PROG ?= outdated
PREFIX ?= /usr
DESTDIR ?=
LIBDIR ?= $(PREFIX)/lib
SYSTEM_EXTENSION_DIR ?= $(LIBDIR)/password-store/extensions

MANDIR ?= $(PREFIX)/share/man

all:
	@echo "pass-$(PROG) is a shell script and does not need compilation, it can be simply executed."
	@echo
	@echo "To install it try \"make install\" instead."
	@echo

install:
	install -d "$(DESTDIR)$(MANDIR)/man1" && install -m 0644 pass-outdated.1 "$(DESTDIR)$(MANDIR)/man1/pass-$(PROG).1"
	install -d "$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/"
	install -m 0755 outdated.bash "$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/$(PROG).bash"
	@echo
	@echo "pass-$(PROG) is installed succesfully"
	@echo

uninstall:
	rm -vrf \
		"$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/$(PROG).bash" \
		"$(DESTDIR)$(MANDIR)/man1/pass-$(PROG).1"
