#!/usr/bin/env bash

set -euo pipefail


docker build -t wid/basic:latest "${WID_CWD}"/tool/docker/basic/