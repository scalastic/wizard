#!/usr/bin/env bash

set -euo pipefail


docker build -t scalastic/wild:latest "${WID_CWD}"/docker/basic/scratch/

docker push scalastic/wild:latest