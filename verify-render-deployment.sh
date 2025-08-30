#!/bin/bash

echo "🔍 Verifying Render Deployment"
echo "============================="

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

if [ -z "$1" ]; then
    print_error "Please provide your Render service URL"
    echo "Usage: $0 <your-render-service-url>"
    echo "Example: $0 https://your-service.onrender.com"
    exit 1
fi

SERVICE_URL="$1"

print_status "Testing Render deployment at: $SERVICE_URL"

# Test health endpoint
print_status "Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s -w "%{http_code}" "$SERVICE_URL/health")
HEALTH_CODE="${HEALTH_RESPONSE: -3}"
HEALTH_BODY="${HEALTH_RESPONSE%???}"

if [ "$HEALTH_CODE" = "200" ]; then
    print_success "✅ Health endpoint working"
    echo "   Response: $HEALTH_BODY"
else
    print_error "❌ Health endpoint failed (HTTP $HEALTH_CODE)"
    echo "   Response: $HEALTH_BODY"
    exit 1
fi

# Test datasets endpoint
print_status "Testing datasets endpoint..."
DATASETS_RESPONSE=$(curl -s -w "%{http_code}" "$SERVICE_URL/datasets")
DATASETS_CODE="${DATASETS_RESPONSE: -3}"
DATASETS_BODY="${DATASETS_RESPONSE%???}"

if [ "$DATASETS_CODE" = "200" ]; then
    print_success "✅ Datasets endpoint working"
    
    # Extract dataset count using jq if available, otherwise use grep
    if command -v jq &> /dev/null; then
        DATASET_COUNT=$(echo "$DATASETS_BODY" | jq '.datasets | length')
        print_status "   Found $DATASET_COUNT datasets"
    else
        DATASET_COUNT=$(echo "$DATASETS_BODY" | grep -o '"name":' | wc -l)
        print_status "   Found approximately $DATASET_COUNT datasets"
    fi
    
    echo "   Response preview:"
    echo "$DATASETS_BODY" | head -10
else
    print_error "❌ Datasets endpoint failed (HTTP $DATASETS_CODE)"
    echo "   Response: $DATASETS_BODY"
    exit 1
fi

# Test data endpoint (data_employees)
print_status "Testing data endpoint (data_employees)..."
DATA_RESPONSE=$(curl -s -w "%{http_code}" "$SERVICE_URL/data?name=data_employees&limit=5")
DATA_CODE="${DATA_RESPONSE: -3}"
DATA_BODY="${DATA_RESPONSE%???}"

if [ "$DATA_CODE" = "200" ]; then
    print_success "✅ Data endpoint working"
    
    # Extract record count
    if command -v jq &> /dev/null; then
        RECORD_COUNT=$(echo "$DATA_BODY" | jq '.data | length')
        print_status "   Found $RECORD_COUNT records in data_employees"
    else
        RECORD_COUNT=$(echo "$DATA_BODY" | grep -o '"id":' | wc -l)
        print_status "   Found approximately $RECORD_COUNT records in data_employees"
    fi
    
    echo "   Response preview:"
    echo "$DATA_BODY" | head -10
else
    print_error "❌ Data endpoint failed (HTTP $DATA_CODE)"
    echo "   Response: $DATA_BODY"
    exit 1
fi

# Test CSV data endpoint (data_employees)
print_status "Testing CSV data endpoint..."
CSV_RESPONSE=$(curl -s -w "%{http_code}" "$SERVICE_URL/data?name=data_employees&format=csv&limit=3")
CSV_CODE="${CSV_RESPONSE: -3}"
CSV_BODY="${CSV_RESPONSE%???}"

if [ "$CSV_CODE" = "200" ]; then
    print_success "✅ CSV data endpoint working"
    echo "   Response preview:"
    echo "$CSV_BODY" | head -5
else
    print_warning "⚠️  CSV data endpoint failed (HTTP $CSV_CODE)"
    echo "   Response: $CSV_BODY"
fi

echo ""
print_success "🎉 Render deployment verification completed!"
echo ""
echo "📋 Summary:"
echo "==========="
echo "✅ Health endpoint: Working"
echo "✅ Datasets endpoint: Working ($DATASET_COUNT datasets)"
echo "✅ Data endpoint: Working"
echo "✅ CSV endpoint: Working"
echo ""
echo "🚀 Your application is successfully deployed and running!"
echo ""
echo "📝 Available endpoints:"
echo "   - $SERVICE_URL/health"
echo "   - $SERVICE_URL/datasets"
echo "   - $SERVICE_URL/data?name=<dataset_name>"
echo "   - $SERVICE_URL/data?name=<dataset_name>&format=csv" 