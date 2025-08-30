#!/bin/bash

echo "🚀 Render.com Deployment Preparation"
echo "===================================="

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

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install Git first."
    exit 1
fi

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_error "Not in a git repository. Please initialize git first:"
    echo "  git init"
    echo "  git remote add origin <your-gitlab-repo-url>"
    exit 1
fi

# Check if render.yaml exists
if [ ! -f "render.yaml" ]; then
    print_error "render.yaml not found. Please ensure it exists in the project root."
    exit 1
fi

# Check if requirements.txt exists
if [ ! -f "requirements.txt" ]; then
    print_error "requirements.txt not found. Please ensure it exists in the project root."
    exit 1
fi

# Check if data-docs directory exists
if [ ! -d "data-docs" ]; then
    print_warning "data-docs directory not found. Creating it..."
    mkdir -p data-docs
    print_success "Created data-docs directory"
fi

# Check if data files exist
if [ ! -f "data-docs/data.json" ] && [ ! -f "data-docs/data.xlsx" ] && [ ! -f "data-docs/mock_data.xlsx" ]; then
    print_warning "No data files found in data-docs/ directory"
    echo "Please add your data files to the data-docs/ directory before deploying."
    echo "Supported formats: .json, .xlsx, .xls, .csv"
fi

# Test build locally
print_status "Testing build locally..."
chmod +x build.sh
./build.sh

if [ $? -ne 0 ]; then
    print_error "Build test failed. Please fix the issues before deploying."
    exit 1
fi

print_success "Build test passed!"

# Check git status
print_status "Checking git status..."
if [ -n "$(git status --porcelain)" ]; then
    print_warning "You have uncommitted changes. Please commit them before deploying:"
    git status --short
    echo ""
    echo "To commit changes:"
    echo "  git add ."
    echo "  git commit -m 'Prepare for Render deployment'"
    echo "  git push origin main"
else
    print_success "No uncommitted changes"
fi

# Show deployment instructions
echo ""
print_success "Your application is ready for Render deployment! 🎉"
echo ""
echo "📋 Deployment Steps:"
echo "==================="
echo ""
echo "1. 📤 Push your code to GitLab:"
echo "   git add ."
echo "   git commit -m 'Add Render deployment configuration'"
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
echo "     • Build Command: pip install -r requirements.txt"
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
echo "   curl \"https://retail-data-service.onrender.com/data?name=data_employees&limit=5\""
echo ""
echo "📚 Documentation:"
echo "================="
echo "• Render Documentation: https://render.com/docs"
echo "• Render Community: https://community.render.com/"
echo "• Render Status: https://status.render.com/"
echo ""
echo "💰 Pricing:"
echo "==========="
echo "• Free Tier: $7/month credit (auto-sleep after 15 min inactivity)"
echo "• Starter: $7/month (always on)"
echo "• Standard: $25/month (better performance)"
echo ""
print_success "Happy deploying! 🚀" 