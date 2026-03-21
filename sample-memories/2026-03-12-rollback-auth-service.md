# Rollback Decision: auth-service v3.1.0 → v3.0.8

**Date:** 2026-03-12
**Agent:** releaser
**ArgoCD App:** auth-service
**Namespace:** production

## Summary

Emergency rollback of `auth-service` from v3.1.0 to v3.0.8 after observing 5xx error rate spike to 12% within 10 minutes of deployment.

## Timeline

- 14:00 UTC — ArgoCD synced auth-service to v3.1.0 (image: registry.ibhacked.us/backend/auth:v3.1.0)
- 14:03 UTC — Grafana alert: 5xx rate exceeded 5% threshold
- 14:06 UTC — Pipeline agent confirmed: error logs show `connection refused` to Redis sentinel
- 14:08 UTC — Deployer confirmed: Redis sentinel endpoint changed in v3.1.0 config
- 14:10 UTC — Rollback initiated via `argocd app rollback auth-service`
- 14:11 UTC — ArgoCD synced back to v3.0.8
- 14:13 UTC — 5xx rate returned to baseline (0.1%)

## Root Cause

v3.1.0 included a Helm values change that pointed Redis sentinel to a new endpoint (`redis-sentinel.data:26379`) that didn't exist in the production namespace. The old endpoint (`redis-ha-sentinel.data:26379`) was correct.

## Lesson Learned

Config changes to external service endpoints should be validated against the target namespace before ArgoCD sync. Consider adding a pre-sync hook that checks endpoint reachability.

## Entities

- auth-service
- v3.1.0
- v3.0.8
- Redis sentinel
- production
- rollback
