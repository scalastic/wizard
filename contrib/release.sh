#!/usr/bin/env bash

set  -eu

run() {
  echo "$@"
  "$@"
}

confirm() {
  printf "%s [y/N] " "$1"
  read -r ans
  case $ans in ([yY] | [yY][eE][sS]) return; esac
  return 1
}

is_prerelease() {
  case $1 in (*-*) return; esac
  return 1
}

version=$(bin/wild --version)

confirm "Release $version?" || exit 0
run git tag -s -a "$version" -m "$version"
run git push origin "$version"

is_prerelease "$version" && exit 0

confirm "Update $version to latest?" || exit 0
run git tag -f latest
run git push -f origin latest