# Deployment Record: staging/web-frontend v2.14.0

**Date:** 2026-03-15
**Agent:** deployer
**Namespace:** staging
**ArgoCD App:** web-frontend

## Summary

Successfully deployed `web-frontend` v2.14.0 to staging namespace. ArgoCD sync completed in 47 seconds.

## Details

- **Image:** registry.ibhacked.us/frontend/web:v2.14.0
- **Previous version:** v2.13.2
- **Replicas:** 3/3 healthy
- **ArgoCD sync status:** Synced
- **ArgoCD health:** Healthy
- **Rollout strategy:** RollingUpdate (maxSurge=1, maxUnavailable=0)

## Observations

- Memory usage increased ~12% compared to v2.13.2 (from 180Mi to 202Mi per pod)
- No errors in first 30 minutes of monitoring
- Grafana dashboard showed stable p99 latency at 45ms

## Entities

- web-frontend
- staging
- v2.14.0
- ArgoCD
