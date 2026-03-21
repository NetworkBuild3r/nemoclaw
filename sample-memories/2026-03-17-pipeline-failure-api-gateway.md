# Pipeline Failure: api-gateway build #847

**Date:** 2026-03-17
**Agent:** pipeline
**GitLab Project:** infrastructure/api-gateway
**Pipeline ID:** 847

## Summary

CI pipeline #847 failed at the `build` stage with OOM kill. The Docker build exceeded the runner's 4GB memory limit while compiling TypeScript with esbuild.

## Root Cause

The `api-gateway` Dockerfile runs `npm run build` which invokes esbuild with `--bundle` on the entire monorepo. A recent merge added 47 new dependencies (PR !312) that pushed peak memory from 3.2GB to 4.6GB.

## Timeline

- 09:12 UTC — Pipeline triggered by merge of !312
- 09:14 UTC — `build` job started on runner `k8s-runner-02`
- 09:18 UTC — OOM kill at `npm run build` step (exit code 137)
- 09:20 UTC — Pipeline marked failed
- 09:45 UTC — Root cause identified: dependency bloat from !312

## Resolution

Increased runner memory limit to 6GB in `.gitlab-ci.yml`. Pipeline #848 succeeded.

## Impact

- Deployment to staging blocked for 33 minutes
- ArgoCD app `api-gateway` remained on v1.22.0 (previous version) during the window

## Entities

- api-gateway
- pipeline-847
- k8s-runner-02
- OOM
- esbuild
