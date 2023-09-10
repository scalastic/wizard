#!/usr/bin/env bash

set -euo pipefail

docker build -t scalastic/wizard:latest "./docker/basic/ubi/"

docker push scalastic/wizard:latest
