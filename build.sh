#!/bin/bash

echo "🚀 Building retail data service for Render..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

# Install dependencies
print_status "Installing Python dependencies..."
pip install -r requirements.txt

# Create data directory if it doesn't exist
print_status "Setting up data directory..."
mkdir -p data-docs

# Check if data files exist
if [ ! -f "data-docs/data.json" ] && [ ! -f "data-docs/data.xlsx" ] && [ ! -f "data-docs/mock_data.xlsx" ]; then
    print_warning "No data files found in data-docs/ directory"
    echo "Please add your data files to the data-docs/ directory:"
    echo "  - data.json"
    echo "  - data.xlsx" 
    echo "  - mock_data.xlsx"
    echo "  - or any other supported files (.csv, .xls)"
else
    print_success "Data files found in data-docs/ directory"
    ls -la data-docs/
fi

# Verify Python version
print_status "Checking Python version..."
python --version

# Test application startup
print_status "Testing application startup..."
python -c "
from app.loader import data_loader
try:
    data_loader.initialize()
    print('✅ Application initialization successful')
except Exception as e:
    print(f'❌ Application initialization failed: {e}')
    exit(1)
"

print_success "Build completed successfully! 🎉"
echo ""
echo "Your application is ready for Render deployment!"
echo "Next steps:"
echo "  1. Push your code to GitLab"
echo "  2. Connect your repository to Render"
echo "  3. Deploy your web service" 