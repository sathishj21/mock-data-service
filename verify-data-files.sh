#!/bin/bash

echo "🔍 Verifying Data Files for Render Deployment"
echo "============================================="

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
    print_error "data-docs directory not found!"
    exit 1
fi

print_status "Checking data files in data-docs directory..."

# Check for mock_data.xlsx specifically
if [ -f "data-docs/mock_data.xlsx" ]; then
    print_success "✅ Found mock_data.xlsx"
    FILE_SIZE=$(du -h data-docs/mock_data.xlsx | cut -f1)
    echo "   Size: $FILE_SIZE"
    echo "   Path: data-docs/mock_data.xlsx"
else
    print_error "❌ mock_data.xlsx not found in data-docs/"
fi

# List all data files
echo ""
print_status "All data files in data-docs directory:"
ls -la data-docs/

echo ""
print_status "File sizes:"
du -h data-docs/*

# Check for supported file types
echo ""
print_status "Checking for supported file types:"
SUPPORTED_FILES=0

if ls data-docs/*.json 2>/dev/null | grep -q .; then
    print_success "✅ JSON files found:"
    ls data-docs/*.json
    SUPPORTED_FILES=$((SUPPORTED_FILES + $(ls data-docs/*.json | wc -l)))
fi

if ls data-docs/*.xlsx 2>/dev/null | grep -q .; then
    print_success "✅ Excel files found:"
    ls data-docs/*.xlsx
    SUPPORTED_FILES=$((SUPPORTED_FILES + $(ls data-docs/*.xlsx | wc -l)))
fi

if ls data-docs/*.xls 2>/dev/null | grep -q .; then
    print_success "✅ Excel files found:"
    ls data-docs/*.xls
    SUPPORTED_FILES=$((SUPPORTED_FILES + $(ls data-docs/*.xls | wc -l)))
fi

if ls data-docs/*.csv 2>/dev/null | grep -q .; then
    print_success "✅ CSV files found:"
    ls data-docs/*.csv
    SUPPORTED_FILES=$((SUPPORTED_FILES + $(ls data-docs/*.csv | wc -l)))
fi

echo ""
if [ $SUPPORTED_FILES -gt 0 ]; then
    print_success "✅ Found $SUPPORTED_FILES supported data files"
else
    print_error "❌ No supported data files found"
    exit 1
fi

# Test application with current data files
echo ""
print_status "Testing application with current data files..."
python3 -c "
from app.loader import data_loader
try:
    data_loader.initialize()
    print('✅ Application initialization successful')
    print('✅ Data files loaded successfully')
except Exception as e:
    print(f'❌ Application initialization failed: {e}')
    exit(1)
"

if [ $? -eq 0 ]; then
    print_success "Application test passed!"
else
    print_error "Application test failed!"
    exit 1
fi

# Check if files are tracked by git (if this is a git repository)
if [ -d ".git" ]; then
    echo ""
    print_status "Checking git status for data files..."
    if git ls-files data-docs/ | grep -q mock_data.xlsx; then
        print_success "✅ mock_data.xlsx is tracked by git"
    else
        print_warning "⚠️  mock_data.xlsx is not tracked by git"
        echo "   This might cause issues with Render deployment"
        echo "   Consider adding it: git add data-docs/mock_data.xlsx"
    fi
fi

echo ""
print_success "🎉 Data files verification completed!"
echo ""
echo "📋 Summary:"
echo "==========="
echo "✅ mock_data.xlsx: $(if [ -f "data-docs/mock_data.xlsx" ]; then echo "Found"; else echo "Missing"; fi)"
echo "✅ Supported files: $SUPPORTED_FILES"
echo "✅ Application test: Passed"
echo ""
echo "🚀 Your data files are ready for Render deployment!"
echo ""
echo "📝 Next steps:"
echo "1. Deploy to Render using the updated render.yaml"
echo "2. The build process will detect your mock_data.xlsx file"
echo "3. Your application should start successfully" 