#!/usr/bin/env bash
# OpenClaw expects workspace bootstrap templates under:
#   <package>/docs/reference/templates/
# System installs under /opt/openclaw often omit docs/, which causes:
#   Missing workspace template: AGENTS.md (/opt/openclaw/docs/reference/templates/AGENTS.md)
# and Telegram replies: "Something went wrong while processing your request."
#
# Run this once after installing/upgrading OpenClaw under /opt/openclaw:
#   sudo ./scripts/install-openclaw-workspace-templates.sh
#
set -euo pipefail
SRC="${SRC:-/home/bnelson/nemoclaw/docs/reference/templates}"
DST="${DST:-/opt/openclaw/docs/reference/templates}"
if [[ ! -d "$SRC" ]]; then
  echo "Source templates not found: $SRC" >&2
  exit 1
fi
echo "Installing workspace templates:"
echo "  from: $SRC"
echo "  to:   $DST"
sudo mkdir -p "$DST"
sudo cp -a "$SRC/." "$DST/"
echo "Done. Restart the gateway: systemctl --user restart openclaw-gateway.service"
