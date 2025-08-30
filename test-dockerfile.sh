#!/bin/bash

echo "🧪 Testing Dockerfile Logic"
echo "=========================="

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

# Create a temporary directory to simulate /app
TEMP_APP_DIR=$(mktemp -d)
print_status "Created temp /app directory: $TEMP_APP_DIR"

# Create data-docs directory
mkdir -p "$TEMP_APP_DIR/data-docs"
print_status "Created data-docs directory at: $TEMP_APP_DIR/data-docs"

# Create data files (same as Dockerfile)
print_status "Creating data files..."

# Create data.json
echo '{
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
}' > "$TEMP_APP_DIR/data-docs/data.json"

# Create data.csv
echo 'id,name,department,salary,email
1,John Doe,IT,75000,john.doe@company.com
2,Jane Smith,HR,65000,jane.smith@company.com
3,Bob Johnson,Sales,70000,bob.johnson@company.com
4,Alice Brown,Marketing,68000,alice.brown@company.com
5,Charlie Wilson,IT,72000,charlie.wilson@company.com' > "$TEMP_APP_DIR/data-docs/data.csv"

# Create products.csv
echo 'id,name,category,price,stock
1,Laptop,Electronics,999.99,50
2,Mouse,Electronics,29.99,100
3,Keyboard,Electronics,79.99,75
4,Monitor,Electronics,299.99,25
5,Headphones,Electronics,149.99,30' > "$TEMP_APP_DIR/data-docs/products.csv"

# Create sample_data.csv
echo 'id,name,department,salary,email
1,John Doe,IT,75000,john.doe@company.com
2,Jane Smith,HR,65000,jane.smith@company.com
3,Bob Johnson,Sales,70000,bob.johnson@company.com
4,Alice Brown,Marketing,68000,alice.brown@company.com
5,Charlie Wilson,IT,72000,charlie.wilson@company.com' > "$TEMP_APP_DIR/data-docs/sample_data.csv"

print_success "✅ Data files created"

# Verify data files were created (same as Dockerfile)
print_status "Verifying data files..."
ls -la "$TEMP_APP_DIR/data-docs/"
echo "Data files created successfully"

# Test application with the created data files
print_status "Testing application with created data files..."
export DATA_DIR="$TEMP_APP_DIR/data-docs"
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
    print_success "🎉 Dockerfile logic test successful!"
else
    print_error "❌ Dockerfile logic test failed!"
    rm -rf "$TEMP_APP_DIR"
    exit 1
fi

# Clean up
rm -rf "$TEMP_APP_DIR"

print_success "🧹 Cleaned up temporary directory"

echo ""
print_success "🎯 Dockerfile logic test completed successfully!"
echo ""
echo "📋 Summary:"
echo "==========="
echo "✅ Data files created correctly"
echo "✅ Application initialization passed"
echo "✅ All tests passed"
echo ""
echo "🚀 Your Dockerfile should work correctly on Render!" 