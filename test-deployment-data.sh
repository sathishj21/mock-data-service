#!/bin/bash

echo "🧪 Testing Deployment Data Files"
echo "================================"

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

# Create test data files
print_status "Creating test data files..."
mkdir -p data-docs

# Create comprehensive sample data files (same as render.yaml)
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

print_success "Test data files created:"
ls -la data-docs/

# Test application initialization
print_status "Testing application initialization..."
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

# Test API endpoints
print_status "Testing API endpoints..."
python3 -c "
import requests
import time

# Start the server in background
import subprocess
import threading

def start_server():
    subprocess.run(['uvicorn', 'app.main:app', '--host', '127.0.0.1', '--port', '8004'], 
                   capture_output=True, text=True)

server_thread = threading.Thread(target=start_server, daemon=True)
server_thread.start()

# Wait for server to start
time.sleep(3)

try:
    # Test health endpoint
    response = requests.get('http://127.0.0.1:8004/health')
    if response.status_code == 200:
        print('✅ Health endpoint working')
    else:
        print(f'❌ Health endpoint failed: {response.status_code}')
    
    # Test datasets endpoint
    response = requests.get('http://127.0.0.1:8004/datasets')
    if response.status_code == 200:
        print('✅ Datasets endpoint working')
        data = response.json()
        print(f'   Found {len(data.get(\"datasets\", []))} datasets')
    else:
        print(f'❌ Datasets endpoint failed: {response.status_code}')
    
    # Test data endpoint
    response = requests.get('http://127.0.0.1:8004/data?name=data_employees&limit=3')
    if response.status_code == 200:
        print('✅ Data endpoint working')
        data = response.json()
        print(f'   Retrieved {len(data.get(\"data\", []))} records')
    else:
        print(f'❌ Data endpoint failed: {response.status_code}')
        
except Exception as e:
    print(f'❌ API test failed: {e}')
"

print_success "Deployment data files are ready! 🎉"
echo ""
echo "📋 Next Steps:"
echo "=============="
echo ""
echo "1. 📤 Deploy to Render:"
echo "   - Go to https://dashboard.render.com/"
echo "   - Create new web service"
echo "   - Use the updated render.yaml"
echo ""
echo "2. 🧪 Test your deployment:"
echo "   curl https://your-service.onrender.com/health"
echo "   curl https://your-service.onrender.com/datasets"
echo "   curl \"https://your-service.onrender.com/data?name=data_employees&limit=5\""
echo ""
print_success "Your deployment should now work! 🚀" 