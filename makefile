PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib
SHELL=bash

.PHONY: all build check metrics test coverage dev

all: build package check metrics coverage doc

build:
	contrib/build.sh

check:
	shellcheck -a -s bash src/*.sh src/lib/*.sh src/lib/ext/gendoc.sh spec/*.sh spec/**/*.sh

coverage:
	shellspec -s bash --kcov

doc:
	contrib/make_doc.sh

metrics:
	contrib/metrics.sh

package:
	contrib/make_package_json.sh > package.json

release:
	contrib/release.sh

test:
	shellspec -s bash

dev:
	shellspec -s bash spec/**/**/gendoc_spec.sh
