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

# Copy mock_data.xlsx file (same as Dockerfile)
print_status "Copying mock_data.xlsx file..."

# Copy the actual mock_data.xlsx file
cp data-docs/mock_data.xlsx "$TEMP_APP_DIR/data-docs/"

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