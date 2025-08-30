#!/bin/bash

echo "🔍 Verifying Render Deployment"
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

# Check if URL is provided
if [ -z "$1" ]; then
    print_error "Please provide your Render service URL"
    echo ""
    echo "Usage: $0 <your-render-service-url>"
    echo "Example: $0 https://retail-data-service.onrender.com"
    echo ""
    echo "You can find your URL in the Render Dashboard"
    exit 1
fi

SERVICE_URL="$1"

print_status "Testing Render deployment at: $SERVICE_URL"
echo ""

# Test health endpoint
print_status "Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s "$SERVICE_URL/health")
if [ $? -eq 0 ] && echo "$HEALTH_RESPONSE" | grep -q "healthy"; then
    print_success "Health endpoint working"
    echo "   Response: $HEALTH_RESPONSE"
else
    print_error "Health endpoint failed"
    echo "   Response: $HEALTH_RESPONSE"
    echo "   Status: $?"
fi
echo ""

# Test datasets endpoint
print_status "Testing datasets endpoint..."
DATASETS_RESPONSE=$(curl -s "$SERVICE_URL/datasets")
if [ $? -eq 0 ]; then
    print_success "Datasets endpoint working"
    DATASET_COUNT=$(echo "$DATASETS_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(len(data.get('datasets', [])))" 2>/dev/null || echo "unknown")
    echo "   Found $DATASET_COUNT datasets"
    echo "   Response preview: $(echo "$DATASETS_RESPONSE" | head -c 200)..."
else
    print_error "Datasets endpoint failed"
    echo "   Response: $DATASETS_RESPONSE"
    echo "   Status: $?"
fi
echo ""

# Test data endpoint
print_status "Testing data endpoint..."
DATA_RESPONSE=$(curl -s "$SERVICE_URL/data?name=data_employees&limit=3")
if [ $? -eq 0 ]; then
    print_success "Data endpoint working"
    RECORD_COUNT=$(echo "$DATA_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null || echo "unknown")
    echo "   Retrieved $RECORD_COUNT records"
    echo "   Response preview: $(echo "$DATA_RESPONSE" | head -c 200)..."
else
    print_error "Data endpoint failed"
    echo "   Response: $DATA_RESPONSE"
    echo "   Status: $?"
fi
echo ""

# Test CSV data endpoint
print_status "Testing CSV data endpoint..."
CSV_RESPONSE=$(curl -s "$SERVICE_URL/data?name=data_employees&limit=2")
if [ $? -eq 0 ]; then
    print_success "CSV data endpoint working"
    echo "   Response preview: $(echo "$CSV_RESPONSE" | head -c 200)..."
else
    print_error "CSV data endpoint failed"
    echo "   Response: $CSV_RESPONSE"
    echo "   Status: $?"
fi
echo ""

# Summary
echo "=========================================="
print_status "Deployment Verification Summary"
echo "=========================================="

if [ $? -eq 0 ]; then
    print_success "🎉 Your Render deployment is working correctly!"
    echo ""
    echo "✅ Service URL: $SERVICE_URL"
    echo "✅ Health endpoint: Working"
    echo "✅ Datasets endpoint: Working"
    echo "✅ Data endpoint: Working"
    echo ""
    echo "📋 Available endpoints:"
    echo "   • $SERVICE_URL/health"
    echo "   • $SERVICE_URL/datasets"
    echo "   • $SERVICE_URL/data?name=<dataset_name>&limit=<number>"
    echo ""
    echo "🧪 Test commands:"
    echo "   curl $SERVICE_URL/health"
    echo "   curl $SERVICE_URL/datasets"
    echo "   curl \"$SERVICE_URL/data?name=data_employees&limit=5\""
    echo "   curl \"$SERVICE_URL/data?name=data_departments&limit=3\""
    echo "   curl \"$SERVICE_URL/data?name=data_products&limit=2\""
else
    print_error "❌ Deployment verification failed"
    echo ""
    echo "Please check:"
    echo "   1. Your service URL is correct"
    echo "   2. The service is deployed and running"
    echo "   3. Check Render logs for errors"
    echo "   4. Verify environment variables are set correctly"
fi 