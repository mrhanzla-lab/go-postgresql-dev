# Deliverables & Screenshots Guide

**Project:** go-postgresql-dev  
**Purpose:** Step-by-step guide to capture all required deliverables and screenshots for the DevOps lab exam

---

## 📋 Required Deliverables Checklist

### 1. GitHub Repository ✅
- [x] Public GitHub repository link
- [x] Working Dockerfile
- [x] docker-compose.yml with PostgreSQL service
- [x] Complete CI/CD workflow (.github/workflows/ci.yml)
- [x] README.md with usage instructions
- [x] devops_report.md documentation

**Your Repository URL:** `https://github.com/mrhanzla-lab/go-postgresql-dev`

---

## 📸 Screenshots Guide

### Screenshot 1: Passing CI/CD Pipeline ✅

**What to capture:** GitHub Actions workflow successfully completing all stages

**Steps:**
1. Navigate to your GitHub repository
2. Click on **Actions** tab
3. Select the **CI/CD Pipeline** workflow
4. Click on the latest successful run (green checkmark)
5. Expand all workflow stages to show:
   - ✅ Build & Install
   - ✅ Lint & Security Scan
   - ✅ Test with Database
   - ✅ Build Docker Image
   - ✅ Deploy (if on main branch)

**Screenshot should include:**
- Green checkmarks for all stages
- Timestamp of the run
- Branch name (main/master)
- Commit message

**How to trigger:**
```powershell
# Make any change and push to main/master branch
git add .
git commit -m "docs: update documentation"
git push origin master
```

**Alternative:** Click on the workflow badge in README.md

---

### Screenshot 2: Running Containers (Docker Compose) 🐳

**What to capture:** Both app and PostgreSQL containers running successfully

**Steps:**
1. Open PowerShell in project directory
2. Run:
   ```powershell
   docker compose up -d
   ```
3. Wait for containers to start (about 30 seconds)
4. Run:
   ```powershell
   docker compose ps
   ```

**Screenshot should show:**
```
NAME                   IMAGE                    STATUS         PORTS
go-postgresql-app      go-postgresql-dev-app    Up X seconds   0.0.0.0:5433->5432/tcp
go-postgresql-db       postgres:16              Up X seconds   0.0.0.0:5432->5432/tcp
```

**Additional verification command:**
```powershell
# Show logs to prove it's working
docker compose logs app

# Should see server startup messages
```

---

### Screenshot 3: Docker Hub Deployment Proof 📦

**What to capture:** Your Docker image successfully pushed to Docker Hub

**Option A: Docker Hub Web Interface**
1. Log in to https://hub.docker.com
2. Navigate to **Repositories**
3. Click on your `go-postgresql` repository
4. Show the **Tags** page with:
   - `latest` tag
   - Recent push timestamp
   - Image size

**Option B: Command Line Pull**
```powershell
# Pull your published image
docker pull {your-username}/go-postgresql:latest

# Run it
docker run -d -p 5432:5432 {your-username}/go-postgresql:latest

# Show running container
docker ps
```

**Screenshot should include:**
- Your Docker Hub username/repository
- Image tags (latest, commit SHAs)
- Push timestamp matching your GitHub Actions run

---

### Screenshot 4: PostgreSQL Connection Test ✅

**What to capture:** Successfully connecting to the running PostgreSQL service

**Prerequisites:**
- Install `psql` client (PostgreSQL command-line tool)
- Or use a GUI tool like pgAdmin or DBeaver

**Using psql:**
```powershell
# Connect to the database
psql -h localhost -p 5432 -U postgres -d testdb

# When prompted, enter password: postgres

# Run a test query
testdb=# SELECT version();
testdb=# \l  # List databases
testdb=# \q  # Quit
```

**Screenshot should show:**
- Successful connection message
- PostgreSQL version output
- Database list

**Alternative: Using Docker exec:**
```powershell
docker compose exec postgres psql -U postgres -d testdb -c "SELECT version();"
```

---

### Screenshot 5: Test Coverage Report 📊

**What to capture:** Codecov dashboard or local coverage report

**Option A: Codecov Dashboard**
1. Navigate to your Codecov project
2. Show coverage percentage
3. Show file-by-file breakdown

**Option B: Local Coverage**
```powershell
# Run tests with coverage
docker compose up -d postgres
go test -v -race -coverprofile=coverage.out ./...

# Generate HTML report
go tool cover -html=coverage.out -o coverage.html

# Open in browser
start coverage.html
```

**Screenshot should show:**
- Overall coverage percentage
- Coverage by package/file
- Covered/uncovered lines highlighted

---

### Screenshot 6: Security Scan Results 🔒

**What to capture:** gosec security scan output

**Steps:**
1. Go to GitHub Actions workflow run
2. Navigate to "Lint & Security Scan" job
3. Expand "Run gosec security scanner" step
4. Download security-scan-results artifact

**Alternative: Run locally:**
```powershell
# Install gosec
go install github.com/securego/gosec/v2/cmd/gosec@latest

# Run scan
gosec -fmt=json -out=gosec-results.json ./...

# View results
cat gosec-results.json
```

**Screenshot should show:**
- Security scan summary
- Number of issues found (if any)
- Severity levels

---

### Screenshot 7: Docker Compose Logs 📝

**What to capture:** Application logs showing successful startup

**Steps:**
```powershell
# Start services
docker compose up -d

# View app logs
docker compose logs app

# View database logs
docker compose logs postgres
```

**Screenshot should show:**
- Application startup messages
- No critical errors
- Server listening messages
- Database initialization (if first run)

---

### Screenshot 8: Pipeline Artifacts 📁

**What to capture:** Uploaded artifacts from CI/CD pipeline

**Steps:**
1. Go to GitHub Actions workflow run
2. Scroll to bottom of the page
3. Show "Artifacts" section with:
   - build-artifacts
   - test-logs
   - security-scan-results
   - docker-build-logs

**Screenshot should show:**
- All artifacts listed
- File sizes
- Retention period (7-30 days)

---

## 🎯 Commands Quick Reference

### Local Development
```powershell
# Clone repository
git clone https://github.com/mrhanzla-lab/go-postgresql-dev.git
cd go-postgresql-dev

# Start all services
docker compose up -d

# View status
docker compose ps

# View logs
docker compose logs -f

# Stop services
docker compose down

# Clean everything
docker compose down -v
```

### Testing
```powershell
# Run tests locally
docker compose up -d postgres
go test -v ./...

# Run with coverage
go test -v -race -coverprofile=coverage.out ./...

# Generate coverage report
go tool cover -html=coverage.out
```

### Building
```powershell
# Build Go application
go build ./examples/go-postgresqld

# Build Docker image
docker build -t go-postgresql:local .

# Run local image
docker run -p 5432:5432 go-postgresql:local
```

### Deployment
```powershell
# Tag and push to Docker Hub (manual)
docker tag go-postgresql:local {username}/go-postgresql:latest
docker push {username}/go-postgresql:latest

# Or let GitHub Actions handle it (automatic on push to main)
git push origin master
```

---

## 🔧 GitHub Secrets Setup

**Required before CI/CD will work:**

Navigate to: `GitHub Repository → Settings → Secrets and variables → Actions → New repository secret`

Add these secrets:

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `DOCKER_USERNAME` | Your Docker Hub username | https://hub.docker.com/settings/general |
| `DOCKER_PASSWORD` | Docker Hub access token | https://hub.docker.com/settings/security → New Access Token |
| `CODECOV_TOKEN` | Codecov upload token | https://codecov.io → Repository settings |

**Important:** Use Docker Hub **Access Token**, not your password!

---

## 📄 Documentation Files Checklist

Ensure you have all these files in your repository:

- [x] `README.md` - Project overview and usage instructions
- [x] `devops_report.md` - Complete DevOps implementation report
- [x] `docker-compose.yml` - Multi-container setup
- [x] `Dockerfile` - Application containerization
- [x] `.github/workflows/ci.yml` - CI/CD pipeline definition
- [x] `DELIVERABLES.md` - This file (screenshots guide)

---

## 🎓 Presentation Tips

### What to Highlight in Your Demo

1. **Project Overview (1 min)**
   - Show README with badges
   - Explain the tech stack (Go + PostgreSQL)

2. **Docker Compose Demo (2 min)**
   - Run `docker compose up -d`
   - Show `docker compose ps`
   - Show logs proving services work
   - Connect to PostgreSQL

3. **CI/CD Pipeline (3 min)**
   - Show GitHub Actions workflow file
   - Walk through the 5 stages
   - Show a successful pipeline run
   - Explain conditional deployment

4. **Security & Quality (1 min)**
   - Show golangci-lint configuration
   - Show gosec security scan results
   - Explain secrets management

5. **Deployment (2 min)**
   - Show Docker Hub repository
   - Pull and run the image
   - Explain rollback strategy

6. **Documentation (1 min)**
   - Show devops_report.md structure
   - Highlight architecture diagram
   - Mention lessons learned

### Common Questions & Answers

**Q: How do you handle database persistence?**  
A: Docker Compose volume `postgres_data` persists data across container restarts.

**Q: What happens if tests fail?**  
A: The pipeline stops before building Docker image, preventing broken code from deploying.

**Q: How do you secure secrets?**  
A: GitHub Secrets for CI/CD, never committed to repository. Docker Hub uses access tokens.

**Q: Can you deploy to production?**  
A: Yes, conditional deployment on main branch. Optional Render/Railway integration included.

**Q: How do you ensure code quality?**  
A: Multi-layer approach: golangci-lint for style, gosec for security, unit/integration tests.

---

## ✅ Final Verification Checklist

Before submission, verify:

- [ ] All 8 screenshots captured
- [ ] GitHub repository is public
- [ ] CI/CD pipeline passes on latest commit
- [ ] Docker image pushed to Docker Hub
- [ ] README.md updated with badges and instructions
- [ ] devops_report.md complete with diagrams
- [ ] All secrets configured in GitHub
- [ ] Docker Compose works locally
- [ ] Tests pass locally and in CI

---

## 🚀 Quick Start for Reviewers

To evaluate this project:

```powershell
# Clone
git clone https://github.com/mrhanzla-lab/go-postgresql-dev.git
cd go-postgresql-dev

# Run locally
docker compose up -d

# Verify services
docker compose ps
docker compose logs

# Connect to database
psql -h localhost -p 5432 -U postgres -d testdb

# Clean up
docker compose down -v
```

**Expected Result:** App and PostgreSQL running, accessible, and working correctly.

---

**Document Created:** October 29, 2025  
**Last Updated:** October 29, 2025  
**Prepared By:** Group-7 DevOps Team
