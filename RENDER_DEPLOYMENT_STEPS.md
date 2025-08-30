# 🚀 Render Deployment Steps

## ✅ **Current Status**
Your data files are now properly set up in the `data-docs` directory:
- `data.json` ✅
- `data.xlsx` ✅  
- `data_array.json` ✅
- `mock_data.xlsx` ✅

## 📋 **Deployment Steps**

### **Step 1: Prepare Your Repository**
```bash
# Your data files are already in data-docs/ directory
# The render.yaml is configured to handle data files properly
```

### **Step 2: Deploy to Render**

1. **Go to Render Dashboard**: https://dashboard.render.com/
2. **Click "New +"** → **"Web Service"**
3. **Connect GitLab** (if not already connected)
4. **Select your repository**: `retail-data-service`
5. **Configure the service**:
   - **Name**: `retail-data-service`
   - **Environment**: `Python`
   - **Build Command**: (already configured in render.yaml)
   - **Start Command**: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
6. **Environment Variables**:
   - `DATA_DIR` = `data-docs`
   - `ENABLE_CORS` = `true`
   - `PYTHON_VERSION` = `3.11.0`
7. **Click "Create Web Service"**

### **Step 3: Monitor Deployment**
- Watch the build logs
- The build process will:
  - Install Python dependencies
  - Set up data files in `/app/data-docs`
  - Start the application

### **Step 4: Test Your Deployment**
Once deployed, test these endpoints:

```bash
# Health check
curl https://your-service.onrender.com/health

# Get datasets
curl https://your-service.onrender.com/datasets

# Get data from specific datasets
curl "https://your-service.onrender.com/data?name=data_employees&limit=5"
curl "https://your-service.onrender.com/data?name=data_departments&limit=5"
```

## 🔧 **What the Updated Configuration Does**

The `render.yaml` now:
1. ✅ **Installs dependencies**: `pip install -r requirements.txt`
2. ✅ **Creates data directory**: `mkdir -p data-docs`
3. ✅ **Handles existing files**: Checks if data files exist
4. ✅ **Creates fallback data**: If no files exist, creates sample data
5. ✅ **Shows file list**: Displays what files are available
6. ✅ **Starts application**: Runs uvicorn with proper configuration

## 🚨 **If Deployment Still Fails**

### **Option 1: Use Docker Deployment**
If the Python deployment fails, try Docker deployment:
1. Use `render-docker.yaml` instead of `render.yaml`
2. Select "Docker" environment in Render
3. Use `Dockerfile.render` for the build

### **Option 2: Manual Data File Upload**
1. Go to your Render service settings
2. Add data files as environment variables or upload them
3. Update the build command to download/use them

### **Option 3: Check Build Logs**
1. Go to your Render service
2. Click "Logs" tab
3. Look for specific error messages
4. Check if data files are being created properly

## 🎯 **Expected Success**
After deployment, you should see:
- ✅ Service status: "Live"
- ✅ Health endpoint: Returns `{"status": "healthy"}`
- ✅ Datasets endpoint: Shows your data files
- ✅ Data endpoint: Returns actual data from your files

## 📞 **Support**
If you still have issues:
1. Check Render documentation: https://render.com/docs
2. Review build logs in Render Dashboard
3. Test locally first: `python3 -c "from app.loader import data_loader; data_loader.initialize()"`

**Your deployment should now work! 🚀** 