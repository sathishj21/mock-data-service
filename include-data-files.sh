#!/bin/bash

echo "📁 Including Data Files for Render Deployment"
echo "============================================"

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

# Check for existing data files in the project
print_status "Looking for data files in the project..."

# Look for common data file locations
DATA_FILES_FOUND=false

# Check if there are any Excel files in the current directory
if ls *.xlsx 2>/dev/null | grep -q .; then
    print_status "Found Excel files in current directory:"
    ls *.xlsx
    print_status "Copying to data-docs..."
    cp *.xlsx data-docs/ 2>/dev/null
    DATA_FILES_FOUND=true
fi

# Check if there are any JSON files in the current directory
if ls *.json 2>/dev/null | grep -q .; then
    print_status "Found JSON files in current directory:"
    ls *.json
    print_status "Copying to data-docs..."
    cp *.json data-docs/ 2>/dev/null
    DATA_FILES_FOUND=true
fi

# Check if there are any CSV files in the current directory
if ls *.csv 2>/dev/null | grep -q .; then
    print_status "Found CSV files in current directory:"
    ls *.csv
    print_status "Copying to data-docs..."
    cp *.csv data-docs/ 2>/dev/null
    DATA_FILES_FOUND=true
fi

# Check if there are any data files in subdirectories
if [ -d "samples" ]; then
    print_status "Checking samples directory..."
    if ls samples/*.xlsx 2>/dev/null | grep -q .; then
        print_status "Found Excel files in samples directory:"
        ls samples/*.xlsx
        print_status "Copying to data-docs..."
        cp samples/*.xlsx data-docs/ 2>/dev/null
        DATA_FILES_FOUND=true
    fi
    if ls samples/*.json 2>/dev/null | grep -q .; then
        print_status "Found JSON files in samples directory:"
        ls samples/*.json
        print_status "Copying to data-docs..."
        cp samples/*.json data-docs/ 2>/dev/null
        DATA_FILES_FOUND=true
    fi
    if ls samples/*.csv 2>/dev/null | grep -q .; then
        print_status "Found CSV files in samples directory:"
        ls samples/*.csv
        print_status "Copying to data-docs..."
        cp samples/*.csv data-docs/ 2>/dev/null
        DATA_FILES_FOUND=true
    fi
fi

# Show what's in data-docs now
print_status "Current contents of data-docs directory:"
if [ -z "$(ls -A data-docs 2>/dev/null)" ]; then
    print_warning "No data files found in data-docs directory"
    echo "Creating sample data files..."
    
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
    
    print_success "Sample data files created"
else
    ls -la data-docs/
    print_success "Data files are ready for deployment"
fi

# Test the application locally
print_status "Testing application with current data files..."
python -c "
from app.loader import data_loader
try:
    data_loader.initialize()
    print('✅ Application initialization successful')
except Exception as e:
    print(f'❌ Application initialization failed: {e}')
    exit(1)
"

if [ $? -eq 0 ]; then
    print_success "Application test passed!"
else
    print_error "Application test failed. Please check your data files."
    exit 1
fi

echo ""
print_success "Data files are ready for Render deployment! 🎉"
echo ""
echo "📋 Next Steps:"
echo "=============="
echo ""
echo "1. 📤 If using Git, commit your changes:"
echo "   git add data-docs/"
echo "   git commit -m 'Add data files for deployment'"
echo "   git push origin main"
echo ""
echo "2. 🌐 Deploy to Render:"
echo "   - Go to https://dashboard.render.com/"
echo "   - Create or update your web service"
echo "   - The updated render.yaml will create data files during build"
echo ""
echo "3. 🧪 Test your deployment:"
echo "   curl https://your-service.onrender.com/health"
echo "   curl https://your-service.onrender.com/datasets"
echo ""
print_success "Your data files are now ready for deployment! 🚀" 