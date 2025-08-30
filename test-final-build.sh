#!/bin/bash

echo "🧪 Final Render Build and Startup Test"
echo "======================================"

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

# Create a temporary directory to simulate Render build
TEMP_DIR=$(mktemp -d)
print_status "Created temporary build directory: $TEMP_DIR"

# Copy application files to temp directory
print_status "Copying application files..."
cp -r app/ $TEMP_DIR/
cp requirements.txt $TEMP_DIR/

# Change to temp directory
cd $TEMP_DIR

print_status "Current directory: $(pwd)"
print_status "Repository contents:"
ls -la

# Simulate the build process (same as render.yaml)
print_status "Running build process..."
echo "Setting up data files for deployment..."

# Debug: Show current directory and contents
echo "Current directory: $(pwd)"
echo "Repository contents:"
ls -la

# Ensure data-docs directory exists in the correct location
mkdir -p data-docs
echo "Created data-docs directory at: $(pwd)/data-docs"

# ALWAYS create data files (don't check for existing ones)
echo "Creating data files for deployment..."

# Create comprehensive sample data files
cat > data-docs/data.json << 'EOF'
{
  "employees": [
    {"id": 1, "name": "John Doe", "department": "IT", "salary": 75000, "email": "john.doe@company.com"},
    {"id": 2, "name": "Jane Smith", "department": "HR", "salary": 65000, "email": "jane.smith@company.com"},
    {"id": 3, "name": "Bob Johnson", "department": "Sales", "salary": 70000, "email": "bob.johnson@company.com"},
    {"id": 4, "name": "Alice Brown", "department": "Marketing", "salary": 68000, "email": "alice.brown@company.com"},
    {"id": 5, "name": "Charlie Wilson", "department": "IT", "salary": 72000, "email": "charlie.wilson@company.com"}
  ],
  "departments": [
    {"id": 1, "name": "IT", "location": "Floor 1", "manager": "John Doe"},
    {"id": 2, "name": "HR", "location": "Floor 2", "manager": "Jane Smith"},
    {"id": 3, "name": "Sales", "location": "Floor 3", "manager": "Bob Johnson"},
    {"id": 4, "name": "Marketing", "location": "Floor 4", "manager": "Alice Brown"}
  ],
  "products": [
    {"id": 1, "name": "Laptop", "category": "Electronics", "price": 999.99, "stock": 50},
    {"id": 2, "name": "Mouse", "category": "Electronics", "price": 29.99, "stock": 100},
    {"id": 3, "name": "Keyboard", "category": "Electronics", "price": 79.99, "stock": 75},
    {"id": 4, "name": "Monitor", "category": "Electronics", "price": 299.99, "stock": 25}
  ]
}
EOF

cat > data-docs/data.csv << 'EOF'
id,name,department,salary,email
1,John Doe,IT,75000,john.doe@company.com
2,Jane Smith,HR,65000,jane.smith@company.com
3,Bob Johnson,Sales,70000,bob.johnson@company.com
4,Alice Brown,Marketing,68000,alice.brown@company.com
5,Charlie Wilson,IT,72000,charlie.wilson@company.com
EOF

cat > data-docs/products.csv << 'EOF'
id,name,category,price,stock
1,Laptop,Electronics,999.99,50
2,Mouse,Electronics,29.99,100
3,Keyboard,Electronics,79.99,75
4,Monitor,Electronics,299.99,25
5,Headphones,Electronics,149.99,30
EOF

cat > data-docs/sample_data.csv << 'EOF'
id,name,department,salary,email
1,John Doe,IT,75000,john.doe@company.com
2,Jane Smith,HR,65000,jane.smith@company.com
3,Bob Johnson,Sales,70000,bob.johnson@company.com
4,Alice Brown,Marketing,68000,alice.brown@company.com
5,Charlie Wilson,IT,72000,charlie.wilson@company.com
EOF

echo "✅ Sample data files created"

# List all data files
echo "📁 Data files in data-docs directory:"
ls -la data-docs/

echo "📊 File sizes:"
du -h data-docs/*

echo "🔍 Absolute path of data-docs:"
echo "$(pwd)/data-docs"

echo "✅ Data files ready for deployment"

# Now simulate the startup process
print_status "Simulating startup process..."
echo "Starting application..."
echo "Current directory: $(pwd)"
echo "Checking data-docs directory:"
ls -la data-docs/ || echo "data-docs directory not found"

# Test application initialization with the correct DATA_DIR
print_status "Testing application initialization..."
export DATA_DIR="$(pwd)/data-docs"
export ENABLE_CORS="true"
export WATCH_FILE="false"

python3 -c "
import sys
sys.path.append('.')
from app.loader import data_loader
try:
    data_loader.initialize()
    print('✅ Application initialization successful')
    print('✅ Data files loaded successfully')
except Exception as e:
    print(f'❌ Application initialization failed: {e}')
    import traceback
    traceback.print_exc()
    exit(1)
"

if [ $? -eq 0 ]; then
    print_success "🎉 Build and startup simulation successful!"
else
    print_error "❌ Build and startup simulation failed!"
    cd /Users/satkotee/projects/ps/retail-data-service
    rm -rf $TEMP_DIR
    exit 1
fi

# Clean up
cd /Users/satkotee/projects/ps/retail-data-service
rm -rf $TEMP_DIR

print_success "🧹 Cleaned up temporary directory"

echo ""
print_success "🎯 Final test completed successfully!"
echo ""
echo "📋 Summary:"
echo "==========="
echo "✅ Build process creates data files correctly"
echo "✅ Startup process finds data files correctly"
echo "✅ Application initialization passes"
echo "✅ All tests passed"
echo ""
echo "🚀 Your render.yaml should work correctly now!" 