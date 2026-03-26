---
name: gitbob-mcp-deploy
description: GitBob's complete MCP server build and deployment workflow. Covers creating repos, CI/CD, runner configs, and reviewing GitLab and K8s results.
---

# GitBob's MCP Deploy Workflow

This skill provides the detailed steps for GitBob to build and deploy MCP servers in the NemoClaw fleet.

## Build Phase
1. **Workspace:** Create your build files under `workspace/mcp/<name>/`. This is your working directory.
2. **Files Needed:**
   - `index.js` - MCP server entry point
   - `package.json` - Node project config 
   - `Dockerfile` - Build container image
   - `.gitlab-ci.yml` - GitLab CI/CD pipeline config (see "Runner Tags" section below)

## GitLab Repo Creation
1. Use the **`create_project`** MCP call with **camelCase** parameters:
   ```json
   {
     "namespaceId": "mcpgroup",
     "name": "mcp-myservice",
     "description": "My MCP Service"
   }
   ```
2. Ensure you have **MCP group access** to create the repo.

## Push Workflow
1. **Always check branch name**: Run `git branch -a` to see what branches exist, then use `master` or `main` accordingly.
2. **Use HTTPS with token**: 
   ```
   git remote add origin https://oauth2:<token>@gitlab.ibhacked.us/mcp/mcp-myservice.git
   git push origin <branch>
   ```
3. **Verify push**: Check the GitLab web UI or API to confirm the push succeeded.

## Runner Tags
**Always include these tags in `.gitlab-ci.yml` for every job:**
```yaml
image: docker:latest
services:
  - docker:dind
 
stages:
  - build
  - deploy

build:
  stage: build
  tags:
    - docker
    - kaniko
  script:
    - # build container image

deploy:
  stage: deploy
  tags: 
    - docker 
    - kaniko
  script:
    - # deploy to K8s
```

## K8s Manifests
After the GitLab pipeline succeeds, **push the k8s manifests** to the `home_k3` GitOps repo.

## Verification Checklist
- [ ] MCP service code is in GitLab repo
- [ ] GitLab pipeline is running successfully 
- [ ] K8s manifests are in home_k3 GitOps repo

## Examples
- Correct `.gitlab-ci.yml` with required tags
- Correct HTTPS remote URL with token
- Camelcase parameters for `create_project`