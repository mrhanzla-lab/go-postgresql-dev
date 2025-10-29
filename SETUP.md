# Quick Setup & Verification Guide

**Project:** go-postgresql-dev  
**Purpose:** Fast setup instructions for the DevOps CI/CD implementation

---

## 🚀 Initial Setup (One-Time)

### 1. Configure GitHub Secrets

Navigate to: `https://github.com/mrhanzla-lab/go-postgresql-dev/settings/secrets/actions`

Click **"New repository secret"** and add each of these:

#### Required Secrets:

**DOCKER_USERNAME**
```
Value: Your Docker Hub username
Example: mrhanzla
```

**DOCKER_PASSWORD**
```
Value: Docker Hub Access Token (NOT your password)
Get it from: https://hub.docker.com/settings/security
Click: "New Access Token" → Copy the token
```

**CODECOV_TOKEN**
```
Value: Your Codecov repository token
Get it from: https://codecov.io/gh/mrhanzla-lab/go-postgresql-dev
Look for: "Repository Upload Token"
```

### 2. Verify GitHub Actions is Enabled

1. Go to repository **Settings** → **Actions** → **General**
2. Ensure "Allow all actions and reusable workflows" is selected
3. Save if changed

---

## 🧪 Local Testing (Before Pushing)

### Test Docker Compose Locally

```powershell
# Navigate to project directory
cd c:\Users\hanzl\OneDrive\Desktop\go-postgresql-dev

# Start services
docker compose up -d

# Check status (both should be "Up")
docker compose ps

# View logs
docker compose logs app
docker compose logs postgres

# Test PostgreSQL connection
docker compose exec postgres psql -U postgres -d testdb -c "SELECT version();"

# Stop when done
docker compose down
```

**Expected Output:**
- ✅ Both containers show status "Up"
- ✅ App logs show server startup
- ✅ PostgreSQL version is displayed
- ✅ No critical errors in logs

### Test Local Build

```powershell
# Build the application
go build ./examples/go-postgresqld

# Run tests (requires PostgreSQL running)
docker compose up -d postgres
go test -v ./postgresql/...

# Clean up
docker compose down
```

---

## 🔄 Triggering the CI/CD Pipeline

### First Pipeline Run

```powershell
# Make sure you're on master/main branch
git branch

# If not, switch to it
git checkout master

# Make a small change to trigger pipeline
echo "# CI/CD Pipeline Active" >> PIPELINE_STATUS.md

# Commit and push
git add .
git commit -m "ci: trigger initial pipeline run"
git push origin master
```

### Watch the Pipeline

1. Go to: `https://github.com/mrhanzla-lab/go-postgresql-dev/actions`
2. Click on the latest workflow run
3. Watch each stage complete:
   - ⏳ Build & Install
   - ⏳ Lint & Security Scan
   - ⏳ Test with Database
   - ⏳ Build Docker Image
   - ⏳ Deploy (if on main branch)

**Expected Duration:** 5-10 minutes for full pipeline

---

## ✅ Verification Checklist

### After First Successful Pipeline Run

- [ ] **GitHub Actions:** All 5 stages show green checkmarks
- [ ] **Docker Hub:** New image appears at `{username}/go-postgresql:latest`
- [ ] **Codecov:** Coverage report uploaded and visible
- [ ] **Artifacts:** Build artifacts, test logs, security scans uploaded
- [ ] **Badges:** CI/CD badge in README shows "passing"

### Local Verification

- [ ] `docker compose up -d` starts both containers
- [ ] `docker compose ps` shows both services healthy
- [ ] PostgreSQL accessible on port 5432
- [ ] App accessible on port 5433
- [ ] No errors in `docker compose logs`

---

## 🐛 Troubleshooting

### Pipeline Fails at "Build Docker Image"

**Problem:** Authentication failure when pushing to Docker Hub

**Solution:**
1. Verify `DOCKER_USERNAME` and `DOCKER_PASSWORD` secrets are set correctly
2. Ensure `DOCKER_PASSWORD` is an **access token**, not your password
3. Check token has "Read, Write, Delete" permissions

**Fix:**
```powershell
# Generate new token at https://hub.docker.com/settings/security
# Update DOCKER_PASSWORD secret in GitHub
```

### Docker Compose: "Port already in use"

**Problem:** Port 5432 or 5433 already occupied

**Solution:**
```powershell
# Check what's using the port
netstat -ano | findstr :5432

# Kill the process or stop conflicting container
docker stop <container-id>

# Or edit docker-compose.yml to use different ports
```

### Tests Fail: "connection refused"

**Problem:** Tests can't connect to PostgreSQL

**Solution:**
```powershell
# Ensure PostgreSQL is running
docker compose up -d postgres

# Wait for health check
docker compose ps

# Check logs
docker compose logs postgres

# Verify connection
docker compose exec postgres pg_isready -U postgres
```

### Pipeline Passes but No Docker Image

**Problem:** Conditional deployment not triggered

**Cause:** You pushed to a branch other than `main` or `master`

**Solution:**
```powershell
# Check current branch
git branch

# Merge to master/main
git checkout master
git merge your-branch
git push origin master
```

---

## 📊 Monitoring & Logs

### View Pipeline Logs

```
GitHub → Actions → CI/CD Pipeline → Latest run → Click stage → Expand steps
```

### View Container Logs

```powershell
# All logs
docker compose logs

# Follow logs in real-time
docker compose logs -f

# Specific service
docker compose logs app
docker compose logs postgres

# Last 50 lines
docker compose logs --tail=50
```

### View Test Coverage

**Online (Codecov):**
```
https://codecov.io/gh/mrhanzla-lab/go-postgresql-dev
```

**Local:**
```powershell
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

---

## 🔐 Security Best Practices

### Secrets Management

✅ **DO:**
- Use GitHub Secrets for all credentials
- Use Docker Hub access tokens (not password)
- Rotate tokens every 90 days
- Limit token permissions to minimum required

❌ **DON'T:**
- Commit secrets to repository
- Share secrets in chat/email
- Use production credentials in dev
- Give tokens more permissions than needed

### Code Security

✅ **Enabled:**
- gosec security scanner (runs on every commit)
- golangci-lint (checks for vulnerabilities)
- Dependabot (GitHub native, optional)

---

## 📈 Performance Tips

### Speed Up Pipeline

Current optimizations:
- ✅ Go module caching (saves ~2 min)
- ✅ Docker layer caching (saves ~3 min)
- ✅ Parallel jobs (lint + build run together)

### Speed Up Local Development

```powershell
# Use cached builds
docker compose up -d --no-build

# Rebuild only when code changes
docker compose up -d --build app

# Keep database running between tests
docker compose up -d postgres
# Then run multiple test cycles without restart
```

---

## 📞 Need Help?

### Common Resources

- **GitHub Actions Docs:** https://docs.github.com/en/actions
- **Docker Compose Docs:** https://docs.docker.com/compose/
- **PostgreSQL Docs:** https://www.postgresql.org/docs/

### Check These First

1. **Pipeline failing?** → Check GitHub Actions logs
2. **Docker issues?** → Run `docker compose logs`
3. **Tests failing?** → Ensure PostgreSQL is running
4. **Can't connect?** → Check ports with `docker compose ps`

---

## 🎯 Next Steps

After successful setup:

1. ✅ Verify all pipeline stages pass
2. ✅ Check Docker Hub for published image
3. ✅ Test pulling and running the image
4. ✅ Capture screenshots (see DELIVERABLES.md)
5. ✅ Review devops_report.md
6. ✅ Prepare presentation

**You're ready to demo! 🎉**

---

**Quick Command Reference:**

```powershell
# Setup
docker compose up -d           # Start all services
docker compose ps             # Check status
docker compose logs -f        # View logs

# Testing
go test -v ./...              # Run tests
go test -cover ./...          # With coverage

# Deployment
git push origin master        # Trigger pipeline

# Cleanup
docker compose down           # Stop services
docker compose down -v        # Stop + remove volumes
```

---

**Created:** October 29, 2025  
**Last Updated:** October 29, 2025  
**Status:** ✅ Ready for Production
