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

coverage:
	shellspec -s bash --kcov

metrics:
	contrib/metrics.sh

package:
	contrib/make_package_json.sh > package.json

release:
	contrib/release.sh

test:
	shellspec -s bash

dev:
	shellspec -s bash spec/**/tooling_spec.sh
