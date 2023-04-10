#!/usr/bin/env bash

export LANG=C

version() {
  ./bin/wild --version
}

files() {
  echo "["
  files="$(find src lib -not -path "*lib/ext*" \( -type f -o -type l \) -exec echo "    \"{}\"," \; | sort)"
  echo "${files%,}"
  echo "  ]"
}

cat<<JSON
{
  "name": "Wild",
  "version": "$(version)",
  "description": "Wild fills the missing link of the DevOps approach and its shift-left principal herein. With Wild the shifts are so close to the developer that they no longer exist.",
  "homepage": "https://scalastic.io/en/",
  "scripts": ["wild"],
  "license": "MIT",
  "files": $(files),
  "install": "make install"
}
JSON