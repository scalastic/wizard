PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
SHELL=bash

.PHONY: build clean check test testall coverage install uninstall

all: test check

build: bin/wild

clean:
	rm -f bin/wild wild.tar.gz

check:
	shellcheck src/* lib/*.sh spec/*.sh examples/*.sh

test:
	shellspec -s bash

dev:
	shellspec -s bash spec/**/sequence_spec.sh

coverage:
	shellspec -s bash --kcov

dist: build
	tar -C bin -czf wild.tar.gz wild

install: build
	mkdir -p $(BINDIR)
	install -m 755 bin/wild $(BINDIR)/wild

uninstall:
	rm -f $(BINDIR)/wild

bin/wild:
	cat src/build.sh  > bin/wild
	chmod +x bin/wild
