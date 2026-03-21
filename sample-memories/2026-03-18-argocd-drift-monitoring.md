# ArgoCD Drift Detection: monitoring-stack

**Date:** 2026-03-18
**Agent:** deployer
**ArgoCD App:** monitoring-stack
**Namespace:** monitoring

## Summary

ArgoCD detected configuration drift in the `monitoring-stack` application. The live Grafana deployment had a manually applied resource limit change that diverged from the Git-declared state.

## Detection

- ArgoCD status changed from `Synced` to `OutOfSync`
- Diff showed: `resources.limits.memory` was `2Gi` in live but `1Gi` in Git
- Someone ran `kubectl edit deployment grafana -n monitoring` directly

## Resolution

Two options were evaluated:
1. **Sync to Git state** — revert the manual change (would restore 1Gi limit)
2. **Update Git** — commit the 2Gi limit to the Helm values

Chose option 2: Grafana had been OOMKilled twice in the past week at 1Gi. The manual change was a valid fix. Updated `apps/monitoring-stack/values.yaml` with `memory: 2Gi`, pushed to GitLab, and ArgoCD auto-synced.

## Entities

- monitoring-stack
- Grafana
- OutOfSync
- drift
- monitoring namespace
- OOMKill
