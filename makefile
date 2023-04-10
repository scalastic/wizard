PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib
SHELL=bash

.PHONY: all build check metrics test coverage dev

all: check coverage metrics

build:
	contrib/build.sh

check:
	shellcheck -a -s bash src/*.sh lib/*.sh spec/lib/*.sh

metrics:
	contrib/metrics.sh

test:
	shellspec -s bash

coverage:
	shellspec -s bash --kcov

dev:
	shellspec -s bash spec/**/tooling_spec.sh
