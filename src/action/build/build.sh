#!/usr/bin/env bash
#@desc Build scripts used in stage

set -euo pipefail

source "./src/common/common.sh"

run() {
  local stage_id="${1}"
  local stage_condition="${2:-}"
  local stage_pre_step="${3:-}"
  local stage_step="${4:-}"
  local stage_post_step="${5:-}"
  local stage_resume="${6:-}"
  local stage_log="${7:-}"
  local stage_log_level="${8:-}"

  log::banner "STAGE ${stage_id}"

  [ "${stage_resume}" = "true" ] && log::info "Resume of Stage ${stage_id}"
}