# 🚂 Railway Deployment Guide

Complete guide to deploy your Go PostgreSQL application to Railway.

---

## 🎯 Overview

Railway is a modern deployment platform that makes it easy to deploy Docker containers with automatic CI/CD, databases, and monitoring.

**Benefits:**
- ✅ Free tier available ($5 credit/month)
- ✅ Automatic HTTPS
- ✅ Built-in PostgreSQL database
- ✅ Environment variables management
- ✅ Automatic deployments from GitHub
- ✅ Easy scaling

---

## 🚀 Method 1: Deploy via Railway Dashboard (Easiest - Recommended)

### **Step 1: Create Railway Account**

1. Go to: https://railway.app
2. Click **"Start a New Project"** or **"Login"**
3. Sign in with GitHub
4. Authorize Railway to access your repositories

### **Step 2: Create New Project**

1. Click **"New Project"**
2. Select **"Deploy from GitHub repo"**
3. Choose **"mrhanzla-lab/go-postgresql-dev"**
4. Railway will automatically detect your Dockerfile

### **Step 3: Add PostgreSQL Database**

1. In your project dashboard, click **"+ New"**
2. Select **"Database"**
3. Choose **"PostgreSQL"**
4. Railway will create and link the database automatically

### **Step 4: Configure Environment Variables**

Railway automatically sets database variables. Add any additional ones:

1. Click on your service
2. Go to **"Variables"** tab
3. Add:
   ```
   PORT=5432
   POSTGRES_HOST=${{PGHOST}}
   POSTGRES_PORT=${{PGPORT}}
   POSTGRES_USER=${{PGUSER}}
   POSTGRES_PASSWORD=${{PGPASSWORD}}
   POSTGRES_DB=${{PGDATABASE}}
   ```

### **Step 5: Deploy**

1. Click **"Deploy"**
2. Railway will:
   - ✅ Pull your code
   - ✅ Build Docker image
   - ✅ Deploy container
   - ✅ Assign public URL

### **Step 6: Get Your URL**

1. Go to **"Settings"** tab
2. Click **"Generate Domain"**
3. Your app will be available at: `https://your-app.up.railway.app`

---

## 🔧 Method 2: Deploy via Railway CLI

### **Step 1: Install Railway CLI**

**On Windows (PowerShell):**
```powershell
npm install -g @railway/cli
```

### **Step 2: Login**

```powershell
railway login
```
This opens a browser for authentication.

### **Step 3: Initialize Project**

```powershell
cd C:\Users\hanzl\OneDrive\Desktop\go-postgresql-dev
railway init
```

### **Step 4: Add PostgreSQL**

```powershell
railway add --database postgresql
```

### **Step 5: Deploy**

```powershell
railway up
```

### **Step 6: Open in Browser**

```powershell
railway open
```

---

## 🤖 Method 3: Automatic Deployment via GitHub Actions (Already Configured!)

Your CI/CD pipeline is already set up for Railway deployment!

### **Step 1: Get Railway API Token**

1. Go to: https://railway.app/account/tokens
2. Click **"Create Token"**
3. Name it: `github-actions`
4. Copy the token

### **Step 2: Get Railway Project ID**

1. Go to your Railway project
2. Open **Settings**
3. Copy **Project ID** (under "General")

### **Step 3: Add GitHub Secrets**

1. Go to: https://github.com/mrhanzla-lab/go-postgresql-dev/settings/secrets/actions
2. Add these secrets:
   - `RAILWAY_TOKEN` = Your Railway API token
   - `RAILWAY_PROJECT_ID` = Your Railway project ID

### **Step 4: Push to Deploy**

```powershell
git commit --allow-empty -m "deploy: trigger railway deployment"
git push origin master
```

Your pipeline will automatically deploy to Railway! 🎉

---

## 📊 Railway Dashboard Features

After deployment, you can:

### **Monitor Application**
- View logs in real-time
- Check CPU and memory usage
- See deployment history

### **Manage Database**
- Access PostgreSQL directly
- View database metrics
- Create backups

### **Configure Networking**
- Custom domains
- Environment variables
- Port configurations

### **Scaling**
- Vertical scaling (increase resources)
- Horizontal scaling (multiple instances)
- Auto-scaling based on load

---

## 🔐 Environment Variables on Railway

Railway automatically provides these PostgreSQL variables:

```bash
PGHOST          # PostgreSQL host
PGPORT          # PostgreSQL port (5432)
PGUSER          # Database user
PGPASSWORD      # Database password
PGDATABASE      # Database name
DATABASE_URL    # Full connection string
```

Your app can use them directly!

---

## 📸 Screenshots for Deliverables

Capture these for your exam:

1. **Railway Project Dashboard**
   - Shows deployed service
   - Database connected
   - Deployment status

2. **Deployment Logs**
   - Build process
   - Container starting
   - Application running

3. **Public URL**
   - Your app accessible online
   - Shows it's working

4. **Database Connection**
   - PostgreSQL instance running
   - Connection details

5. **GitHub Actions Integration**
   - Railway deployment step
   - Success logs

---

## 🎯 Quick Start Commands

```powershell
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Create new project
railway init

# Add PostgreSQL
railway add --database postgresql

# Link to existing project
railway link

# Deploy
railway up

# View logs
railway logs

# Open dashboard
railway open

# Check status
railway status
```

---

## ✅ Deployment Checklist

- [ ] Railway account created
- [ ] New project created from GitHub
- [ ] PostgreSQL database added
- [ ] Environment variables configured
- [ ] Application deployed successfully
- [ ] Public URL generated
- [ ] Database connected
- [ ] Railway API token obtained
- [ ] GitHub secrets configured (RAILWAY_TOKEN, RAILWAY_PROJECT_ID)
- [ ] CI/CD automatic deployment working

---

## 🔗 Important Links

- **Railway Dashboard:** https://railway.app/dashboard
- **Railway Docs:** https://docs.railway.app
- **API Tokens:** https://railway.app/account/tokens
- **GitHub Integration:** https://docs.railway.app/deploy/github
- **PostgreSQL Plugin:** https://docs.railway.app/databases/postgresql
- **CLI Docs:** https://docs.railway.app/develop/cli

---

## 🎉 Final Result

After successful deployment:

```
✅ Application running at: https://your-app.up.railway.app
✅ PostgreSQL database connected
✅ Automatic deployments on git push
✅ HTTPS enabled
✅ Logs and monitoring available
✅ Ready for production use
```

---

**Railway is perfect for your DevOps lab! It provides all the features you need with minimal setup.** 🚀
