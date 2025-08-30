#!/bin/bash

echo "🚀 Preparing Render Deployment"
echo "=============================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if data-docs directory exists
if [ ! -d "data-docs" ]; then
    print_status "Creating data-docs directory..."
    mkdir -p data-docs
fi

# Check if there are any data files
if [ -z "$(ls -A data-docs 2>/dev/null)" ]; then
    print_warning "No data files found in data-docs/ directory"
    echo "Creating sample data files for deployment..."
    
    # Create sample JSON data
    cat > data-docs/sample.json << 'EOF'
{
  "employees": [
    {"id": 1, "name": "John Doe", "department": "IT", "salary": 75000},
    {"id": 2, "name": "Jane Smith", "department": "HR", "salary": 65000},
    {"id": 3, "name": "Bob Johnson", "department": "Sales", "salary": 70000}
  ],
  "departments": [
    {"id": 1, "name": "IT", "location": "Floor 1"},
    {"id": 2, "name": "HR", "location": "Floor 2"},
    {"id": 3, "name": "Sales", "location": "Floor 3"}
  ]
}
EOF
    
    # Create sample CSV data
    cat > data-docs/sample.csv << 'EOF'
id,name,department,salary
1,John Doe,IT,75000
2,Jane Smith,HR,65000
3,Bob Johnson,Sales,70000
EOF
    
    print_success "Sample data files created:"
    echo "  - data-docs/sample.json"
    echo "  - data-docs/sample.csv"
else
    print_success "Data files found in data-docs/ directory:"
    ls -la data-docs/
fi

# Ensure data files are tracked by git
print_status "Checking git status for data files..."
if [ -n "$(git status --porcelain data-docs/ 2>/dev/null)" ]; then
    print_warning "Data files have changes. Adding to git..."
    git add data-docs/
    git commit -m "Add data files for Render deployment" 2>/dev/null || echo "No changes to commit"
fi

# Test the build locally
print_status "Testing build locally..."
chmod +x build.sh
./build.sh

if [ $? -ne 0 ]; then
    print_error "Build test failed. Please fix the issues before deploying."
    exit 1
fi

print_success "Build test passed!"

# Show deployment instructions
echo ""
print_success "Your repository is ready for Render deployment! 🎉"
echo ""
echo "📋 Next Steps:"
echo "=============="
echo ""
echo "1. 📤 Push your code to GitLab:"
echo "   git add ."
echo "   git commit -m 'Prepare for Render deployment'"
echo "   git push origin main"
echo ""
echo "2. 🌐 Deploy to Render:"
echo "   - Go to https://dashboard.render.com/"
echo "   - Click 'New +' → 'Web Service'"
echo "   - Connect your GitLab account"
echo "   - Select your repository: retail-data-service"
echo "   - Configure the service:"
echo "     • Name: retail-data-service"
echo "     • Environment: Python"
echo "     • Build Command: (already configured in render.yaml)"
echo "     • Start Command: uvicorn app.main:app --host 0.0.0.0 --port \$PORT"
echo ""
echo "3. ⚙️  Environment Variables:"
echo "   • DATA_DIR = data-docs"
echo "   • ENABLE_CORS = true"
echo "   • PYTHON_VERSION = 3.11.0"
echo ""
echo "4. 🚀 Deploy:"
echo "   - Click 'Create Web Service'"
echo "   - Wait for deployment to complete"
echo "   - Your service will be available at: https://retail-data-service.onrender.com"
echo ""
echo "5. 🧪 Test your deployment:"
echo "   curl https://retail-data-service.onrender.com/health"
echo "   curl https://retail-data-service.onrender.com/datasets"
echo "   curl \"https://retail-data-service.onrender.com/data?name=sample_employees&limit=5\""
echo ""
print_success "Happy deploying! 🚀" 