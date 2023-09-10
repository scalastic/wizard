#!/usr/bin/env bash
#
# Creates a package.json file for Wizard

export LANG=C

version() {
  ./bin/wizard --version
}

files() {
  echo "["
  files="$(find src -not -path "*lib/ext*" -not -name ".DS_Store" \( -type f -o -type l \) -exec echo "    \"{}\"," \; | sort)"
  echo "${files%,}"
  echo "  ]"
}

cat<<JSON
{
  "name": "Wizard",
  "version": "$(version)",
  "description": "Welcome to Wizard, a versatile and magical framework that empowers you to effortlessly execute uniform integration scripts both locally and on your server.",
  "homepage": "https://scalastic.io/en/",
  "scripts": ["wizard"],
  "license": "MIT",
  "files": $(files),
  "install": "make install"
}
JSON