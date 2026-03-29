#!/usr/bin/env bash
# Run from repo root before pushing to a public GitHub fork. Fails on common foot-guns.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== 1. Tracked secret-like patterns (first hits only) =="
# Exclude obvious placeholders and docs that say "ghp_..." as examples
if OUT=$(git grep -nE '(sk-ant-api|sk-proj-|sk_live_|xox[bap]-[0-9a-zA-Z-]{10,})' -- . 2>/dev/null | grep -vE 'node_modules/|\.pyc$' || true); test -n "$OUT"; then
  echo "$OUT"
  echo "FAIL: Remove or redact before public push."
  exit 1
fi
echo "    (none matched high-risk prefixes)"

echo "== 2. config/mcporter.json must not be tracked (use .example) =="
if git ls-files | grep -qx 'config/mcporter.json'; then
  echo "FAIL: config/mcporter.json is tracked — git rm --cached config/mcporter.json"
  exit 1
fi
echo "    ok"

echo "== 3. stack/litellm-config.yaml must not be tracked =="
if git ls-files | grep -qx 'stack/litellm-config.yaml'; then
  echo "FAIL: stack/litellm-config.yaml is tracked"
  exit 1
fi
echo "    ok"

echo "== 4. node_modules / venv must not be tracked =="
if git ls-files | grep -qE '(^|/)node_modules/|(^|/)venv/|(^|/)\.venv/'; then
  git ls-files | grep -E '(^|/)node_modules/|(^|/)venv/|(^|/)\.venv/' | head -20
  echo "FAIL: Remove from index (git rm -r --cached …)"
  exit 1
fi
echo "    ok"

echo "== 5. Private GitOps gitlink (agents/github-bob/home_k3) must not be in index =="
if git ls-files | grep -qx 'agents/github-bob/home_k3'; then
  echo "FAIL: Run: git rm --cached agents/github-bob/home_k3"
  echo "     (folder stays on disk; already in .gitignore)"
  exit 1
fi
echo "    ok"

echo "== 6. No agents/**/mcporter.json in index (use config/mcporter.json locally) =="
if git ls-files | grep -qE '^agents/[^/]+/mcporter\.json$'; then
  git ls-files | grep -E '^agents/[^/]+/mcporter\.json$'
  echo "FAIL: git rm --cached agents/<agent>/mcporter.json (see .gitignore)"
  exit 1
fi
echo "    ok"

echo "== All checks passed. Review docs/GITHUB-SUBMISSION.md before push. =="
