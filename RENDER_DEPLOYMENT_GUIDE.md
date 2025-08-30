# 🚀 Render.com Deployment Guide

Render.com is an excellent platform for deploying your retail data service. It's simple, has a generous free tier, and integrates seamlessly with GitLab.

## 🎯 **Why Render.com?**

### **Key Advantages:**
- ✅ **Simple setup**: No complex infrastructure management
- ✅ **Free tier**: $7/month free credit, then pay-as-you-go
- ✅ **GitLab integration**: Direct deployment from private GitLab repos
- ✅ **Automatic deployments**: Deploy on every push
- ✅ **Built-in SSL**: HTTPS certificates included
- ✅ **Global CDN**: Fast worldwide access
- ✅ **No vendor lock-in**: Easy to migrate later

### **Cost Comparison:**
| Platform | Monthly Cost | Setup Complexity | Best For |
|----------|-------------|------------------|----------|
| **Render.com** | $7-25 | Low | Development, small-medium apps |
| **Other Platforms** | $25+ | Medium-High | Enterprise applications |

---

## 🚀 **Option 1: Web Service Deployment (Recommended)**

### **Step 1: Prepare Your Application**

#### 1.1 Create Render Configuration
Create `render.yaml` in your project root:
```yaml
services:
  - type: web
    name: retail-data-service
    env: python
    buildCommand: pip install -r requirements.txt
    startCommand: uvicorn app.main:app --host 0.0.0.0 --port $PORT
    envVars:
      - key: DATA_DIR
        value: data-docs
      - key: ENABLE_CORS
        value: true
      - key: PYTHON_VERSION
        value: 3.11.0
```

#### 1.2 Update Requirements
Ensure your `requirements.txt` includes:
```txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
pandas==2.1.3
openpyxl==3.1.2
watchdog==3.0.0
pydantic==2.5.0
```

#### 1.3 Create Build Script (Optional)
Create `build.sh` for custom build steps:
```bash
#!/bin/bash
echo "Building retail data service..."

# Install dependencies
pip install -r requirements.txt

# Create data directory if it doesn't exist
mkdir -p data-docs

# Copy sample data if needed
if [ ! -f "data-docs/data.json" ]; then
    echo "No data files found. Please add your data files to data-docs/ directory."
fi

echo "Build completed!"
```

### **Step 2: Deploy to Render**

#### 2.1 Connect GitLab Repository
1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Click "New +" → "Web Service"
3. Connect your GitLab account
4. Select your private repository: `retail-data-service`

#### 2.2 Configure Service
```
Name: retail-data-service
Environment: Python
Build Command: pip install -r requirements.txt
Start Command: uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

#### 2.3 Environment Variables
Add these environment variables:
```
DATA_DIR = data-docs
ENABLE_CORS = true
PYTHON_VERSION = 3.11.0
```

#### 2.4 Deploy
Click "Create Web Service" and Render will:
- Clone your repository
- Install dependencies
- Build your application
- Deploy to a public URL

### **Step 3: Test Your Deployment**

#### 3.1 Get Your Service URL
Your service will be available at:
```
https://retail-data-service.onrender.com
```

#### 3.2 Test Endpoints
```bash
# Health check
curl https://retail-data-service.onrender.com/health

# Get datasets
curl https://retail-data-service.onrender.com/datasets

# Get data
curl "https://retail-data-service.onrender.com/data?name=data_employees&limit=5"
```

---

## 🐳 **Option 2: Docker Deployment**

### **Step 1: Create Dockerfile**
Create `Dockerfile.render`:
```dockerfile
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/
COPY data-docs/ ./data-docs/

# Expose port
EXPOSE 8000

# Set environment variables
ENV DATA_DIR=/app/data-docs
ENV ENABLE_CORS=true

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### **Step 2: Create Render Configuration**
Create `render.yaml`:
```yaml
services:
  - type: web
    name: retail-data-service-docker
    env: docker
    dockerfilePath: ./Dockerfile.render
    envVars:
      - key: DATA_DIR
        value: /app/data-docs
      - key: ENABLE_CORS
        value: true
```

### **Step 3: Deploy**
1. Go to Render Dashboard
2. Click "New +" → "Web Service"
3. Connect GitLab repository
4. Select "Docker" environment
5. Deploy

---

## 🔄 **Automatic Deployments**

### **GitLab Integration**
Render automatically deploys when you:
- Push to `main` branch
- Create a new tag
- Manually trigger deployment

### **Deployment Settings**
In your Render service settings:
- **Auto-Deploy**: Enabled (deploys on every push)
- **Branch**: `main`
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

---

## 📊 **Monitoring and Logs**

### **View Logs**
1. Go to your service in Render Dashboard
2. Click "Logs" tab
3. View real-time application logs

### **Health Checks**
Your application includes health checks:
```bash
curl https://your-service.onrender.com/health
```

### **Performance Monitoring**
Render provides:
- Response time metrics
- Error rates
- Resource usage

---

## 🔧 **Environment Variables**

### **Required Variables**
```
DATA_DIR = data-docs
ENABLE_CORS = true
```

### **Optional Variables**
```
WATCH_FILE = false
HOST = 0.0.0.0
PORT = 8000
```

---

## 🚨 **Troubleshooting**

### **Common Issues**

#### 1. Build Failures
```bash
# Check build logs in Render Dashboard
# Common fixes:
# - Update requirements.txt
# - Check Python version compatibility
# - Verify file paths
```

#### 2. Application Not Starting
```bash
# Check start command
# Verify PORT environment variable
# Check application logs
```

#### 3. Data Files Not Found
```bash
# Ensure data-docs/ directory exists
# Check DATA_DIR environment variable
# Verify file permissions
```

### **Debug Commands**
```bash
# Test locally before deploying
uvicorn app.main:app --host 0.0.0.0 --port 8000

# Check environment variables
echo $DATA_DIR
echo $ENABLE_CORS

# Test data loading
python -c "from app.loader import data_loader; data_loader.initialize()"
```

---

## 💰 **Cost Optimization**

### **Free Tier**
- $7/month free credit
- Perfect for development and testing
- Auto-sleep after 15 minutes of inactivity

### **Paid Plans**
- **Starter**: $7/month (always on)
- **Standard**: $25/month (better performance)
- **Pro**: Custom pricing (enterprise features)

### **Cost Saving Tips**
1. Use free tier for development
2. Enable auto-sleep for non-critical services
3. Monitor resource usage
4. Use appropriate instance sizes

---

## 🔒 **Security**

### **Built-in Security**
- ✅ **HTTPS**: Automatic SSL certificates
- ✅ **Environment Variables**: Secure configuration
- ✅ **Private Repos**: GitLab integration
- ✅ **Network Isolation**: VPC-like isolation

### **Best Practices**
1. Use environment variables for sensitive data
2. Keep dependencies updated
3. Monitor logs for security issues
4. Use private GitLab repositories

---

## 🚀 **Quick Start Commands**

### **1. Prepare Your Repository**
```bash
# Add render.yaml to your repository
# Ensure requirements.txt is up to date
# Add data files to data-docs/ directory

git add render.yaml
git commit -m "Add Render deployment configuration"
git push origin main
```

### **2. Deploy to Render**
1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Click "New +" → "Web Service"
3. Connect GitLab and select your repository
4. Configure environment variables
5. Deploy

### **3. Test Deployment**
```bash
# Get your service URL from Render Dashboard
SERVICE_URL="https://your-service.onrender.com"

# Test endpoints
curl $SERVICE_URL/health
curl $SERVICE_URL/datasets
curl "$SERVICE_URL/data?name=data_employees&limit=5"
```

---

## 📚 **Next Steps**

### **After Deployment**
1. **Monitor logs** in Render Dashboard
2. **Set up alerts** for errors
3. **Configure custom domain** (optional)
4. **Set up monitoring** (optional)

### **Advanced Features**
1. **Custom domains**: Point your domain to Render
2. **Background workers**: For long-running tasks
3. **Cron jobs**: Scheduled tasks
4. **Databases**: PostgreSQL, Redis, etc.

---

## 🎉 **Success Checklist**

- [ ] Repository prepared with `render.yaml`
- [ ] Requirements.txt updated
- [ ] Data files in `data-docs/` directory
- [ ] GitLab repository connected to Render
- [ ] Environment variables configured
- [ ] Service deployed successfully
- [ ] Health endpoint responding
- [ ] Datasets endpoint working
- [ ] Data endpoint returning results
- [ ] Logs accessible in Render Dashboard

---

## 📞 **Support**

### **Render Support**
- [Render Documentation](https://render.com/docs)
- [Render Community](https://community.render.com/)
- [Render Status](https://status.render.com/)

### **Troubleshooting Resources**
1. Check Render documentation
2. Review application logs
3. Test locally first
4. Contact Render support if needed

**Congratulations! Your application is now deployed on Render.com! 🚀** 