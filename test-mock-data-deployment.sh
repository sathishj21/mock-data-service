#!/bin/bash

echo "🧪 Testing Mock Data Deployment"
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

# Check if mock_data.xlsx exists
if [ ! -f "data-docs/mock_data.xlsx" ]; then
    print_error "❌ mock_data.xlsx not found in data-docs/"
    exit 1
fi

print_success "✅ Found mock_data.xlsx"
FILE_SIZE=$(du -h data-docs/mock_data.xlsx | cut -f1)
print_status "File size: $FILE_SIZE"

# Test application with mock_data.xlsx
print_status "Testing application with mock_data.xlsx..."
export DATA_DIR="data-docs"
export ENABLE_CORS="true"
export WATCH_FILE="false"

python3 -c "
import sys
sys.path.append('.')
from app.loader import data_loader
try:
    data_loader.initialize()
    print('✅ Application initialization successful')
    print('✅ mock_data.xlsx loaded successfully')
except Exception as e:
    print(f'❌ Application initialization failed: {e}')
    import traceback
    traceback.print_exc()
    exit(1)
"

if [ $? -eq 0 ]; then
    print_success "🎉 Mock data deployment test successful!"
else
    print_error "❌ Mock data deployment test failed!"
    exit 1
fi

echo ""
print_success "🎯 Mock data deployment test completed successfully!"
echo ""
echo "📋 Summary:"
echo "==========="
echo "✅ mock_data.xlsx file exists ($FILE_SIZE)"
echo "✅ Application loads mock_data.xlsx successfully"
echo "✅ All tests passed"
echo ""
echo "🚀 Your deployment will now use your actual mock_data.xlsx file!"
echo ""
echo "📝 Expected datasets from mock_data.xlsx:"
echo "   - mock_data_Use_Cases"
echo "   - mock_data_Real_time_inv"
echo "   - mock_data_Real_time_Sales"
echo "   - mock_data_Supplier_Info"
echo "   - mock_data_ASN"
echo "   - mock_data_Campaign_Performance_KPIs"
echo "   - mock_data_Product"
echo "   - mock_data_Beach_Wear"
echo "   - mock_data_Last_Mile"
echo "   - data_Employees"
echo "   - data_Departments" 