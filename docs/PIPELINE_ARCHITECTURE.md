# CI/CD Pipeline - Clean Architecture

## 📋 Pipeline Overview

This is a **clean, from-scratch implementation** of the CI/CD pipeline with exactly **5 stages** as required.

---

## 🎯 Pipeline Stages

### **Stage 1: Build & Install**
```yaml
✓ Checkout code
✓ Set up Go 1.23.x
✓ Cache Go modules
✓ Download dependencies
✓ Build application (go build -v ./...)
✓ Build example server (bin/go-postgresqld)
✓ Upload build artifacts
```

### **Stage 2: Lint/Security Scan**
```yaml
✓ Checkout code
✓ Set up Go 1.23.x
✓ Run golangci-lint (code quality)
✓ Install gosec
✓ Run gosec security scanner
✓ Upload security scan results (JSON)
```

### **Stage 3: Test (with DB service)**
```yaml
✓ PostgreSQL service (GitHub Actions services)
  - Image: postgres:16
  - Port: 5432
  - Health checks enabled
✓ Checkout code
✓ Set up Go 1.23.x
✓ Cache Go modules
✓ Run tests with coverage
✓ Upload coverage to Codecov (optional)
✓ Upload test artifacts
```

### **Stage 4: Build Docker Image**
```yaml
✓ Checkout code
✓ Set up Docker Buildx
✓ Log in to Docker Hub (if pushing)
✓ Extract metadata (tags, labels)
✓ Build and push Docker image
  - Uses GitHub Actions cache
  - Multi-platform support ready
```

### **Stage 5: Deploy (Conditional)**
```yaml
Conditions:
  - Tests MUST pass (needs: [docker-build])
  - Branch MUST be 'main' or 'master'
  
✓ Deploy notification
✓ Create deployment summary
✓ Log deployment details
```

---

## 🔧 Key Features

### **1. Conditional Deployment**
```yaml
if: github.event_name == 'push' && 
    (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master')
```
- ✅ Only deploys when tests pass
- ✅ Only deploys from main/master branch
- ✅ PR builds don't trigger deployment

### **2. PostgreSQL Service Integration**
```yaml
services:
  postgres:
    image: postgres:16
    env:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: testdb
    ports:
      - 5432:5432
    options: >-
      --health-cmd pg_isready
      --health-interval 10s
      --health-timeout 5s
      --health-retries 5
```
- ✅ Runs PostgreSQL 16 as a service
- ✅ Health checks ensure DB is ready
- ✅ Available at localhost:5432

### **3. Build Caching**
```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.cache/go-build
      ~/go/pkg/mod
    key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
```
- ✅ Faster builds (caches Go modules)
- ✅ Reduces CI time
- ✅ Cache invalidates on dependency changes

### **4. Error Handling**
```yaml
if: always()              # Run even if previous steps fail
continue-on-error: true   # Don't fail pipeline if optional step fails
if-no-files-found: ignore # Don't fail if artifacts missing
```

---

## 📊 Pipeline Dependencies

```
┌─────────────────┐
│  Build & Install │
└────────┬────────┘
         │
         ├─────────────────┐
         │                 │
┌────────▼────────┐ ┌─────▼──────────┐
│ Lint/Security   │ │ Test (DB)      │
└────────┬────────┘ └─────┬──────────┘
         │                 │
         └────────┬────────┘
                  │
         ┌────────▼────────┐
         │ Build Docker    │
         └────────┬────────┘
                  │
         ┌────────▼────────┐
         │ Deploy          │
         │ (Conditional)   │
         └─────────────────┘
```

**Stage Dependencies:**
- Stage 4 requires: Stages 1, 2, 3 to pass
- Stage 5 requires: Stage 4 to pass + branch condition

---

## 🚀 Triggering the Pipeline

### **Automatic Triggers**
```yaml
on:
  push:
    branches: [ "master", "main" ]
  pull_request:
    branches: [ "master", "main" ]
```

- ✅ Triggers on push to main/master
- ✅ Triggers on pull requests
- ✅ Manual re-run available in GitHub UI

---

## 🔐 Required Secrets

Configure in: **Settings → Secrets and variables → Actions**

| Secret | Required? | Purpose |
|--------|-----------|---------|
| `DOCKER_USERNAME` | ✅ Yes | Docker Hub username |
| `DOCKER_PASSWORD` | ✅ Yes | Docker Hub access token |
| `CODECOV_TOKEN` | ⚠️ Optional | Code coverage reporting |

**Note:** Pipeline will succeed without secrets, but Docker push will be skipped.

---

## 📁 Files Modified

### **Deleted:**
- ❌ `.github/workflows/make.yml` - Removed old test workflow
- ❌ Old version of `ci.yml` - Replaced with clean version

### **Created:**
- ✅ `.github/workflows/ci.yml` - Brand new, clean pipeline

### **Changes:**
- 📉 Reduced complexity: 120 lines → 33 lines changed
- 🎯 Focused on 5 essential stages only
- 🧹 Removed redundant steps and configurations
- 📝 Clear, commented stage definitions

---

## ✅ Verification Checklist

Before deploying, verify:

```bash
# 1. Local build works
go build -v ./...

# 2. Tests pass locally
go test -v ./...

# 3. Docker build works
docker build -t test-build .

# 4. Docker Compose works
docker compose up -d
docker compose ps
```

---

## 📸 Expected Outputs

### **Stage 1: Build & Install**
```
✓ All packages compiled
✓ Binary created: bin/go-postgresqld
✓ Artifacts uploaded (7 days retention)
```

### **Stage 2: Lint/Security Scan**
```
✓ golangci-lint: No issues found
✓ gosec: Security scan complete
✓ Results: gosec-results.json uploaded
```

### **Stage 3: Test (with DB service)**
```
✓ PostgreSQL service running
✓ All tests passed
✓ Coverage: X.X%
✓ Coverage report uploaded
```

### **Stage 4: Build Docker Image**
```
✓ Docker image built
✓ Tags: latest, master-abc123
✓ Image pushed to Docker Hub (if main branch)
```

### **Stage 5: Deploy (Conditional)**
```
✓ Deployment summary created
✓ Image available: username/go-postgresql:latest
✓ Ready for production use
```

---

## 🎓 Pipeline Best Practices

1. **Separation of Concerns** - Each stage has a specific purpose
2. **Fail Fast** - Build before running expensive tests
3. **Parallel Execution** - Lint and Test can run in parallel
4. **Conditional Deployment** - Only deploy stable code
5. **Artifact Retention** - Keep builds for 7 days, test results for 30 days

---

## 🔗 Quick Links

- **Repository:** https://github.com/mrhanzla-lab/go-postgresql-dev
- **Actions:** https://github.com/mrhanzla-lab/go-postgresql-dev/actions
- **Docker Hub:** (Configure with your username)
- **Codecov:** https://codecov.io (Optional integration)

---

**Created:** October 29, 2025  
**Pipeline Version:** 1.0 (Clean Build)  
**Status:** ✅ Active
