#!/usr/bin/env bash

set -euo pipefail

docker build -t scalastic/wild:latest "./docker/basic/ubi/"

docker push scalastic/wild:latest
