#!/bin/bash

echo "🧪 Testing Absolute Path Approach"
echo "================================"

# Create a temporary directory to simulate /app
TEMP_APP_DIR=$(mktemp -d)
echo "Created temp /app directory: $TEMP_APP_DIR"

# Create data-docs directory in the temp /app
mkdir -p "$TEMP_APP_DIR/data-docs"
echo "Created data-docs directory at: $TEMP_APP_DIR/data-docs"

# Create sample data files
echo "Creating sample data files..."

cat > "$TEMP_APP_DIR/data-docs/data.json" << 'EOF'
{
  "employees": [
    {"id": 1, "name": "John Doe", "department": "IT", "salary": 75000, "email": "john.doe@company.com"},
    {"id": 2, "name": "Jane Smith", "department": "HR", "salary": 65000, "email": "jane.smith@company.com"},
    {"id": 3, "name": "Bob Johnson", "department": "Sales", "salary": 70000, "email": "bob.johnson@company.com"}
  ]
}
EOF

cat > "$TEMP_APP_DIR/data-docs/data.csv" << 'EOF'
id,name,department,salary,email
1,John Doe,IT,75000,john.doe@company.com
2,Jane Smith,HR,65000,jane.smith@company.com
3,Bob Johnson,Sales,70000,bob.johnson@company.com
EOF

echo "✅ Sample data files created"

# List all data files
echo "📁 Data files in $TEMP_APP_DIR/data-docs directory:"
ls -la "$TEMP_APP_DIR/data-docs/"

echo "📊 File sizes:"
du -h "$TEMP_APP_DIR/data-docs/"*

echo "✅ Absolute path approach test completed successfully!"

# Clean up
rm -rf "$TEMP_APP_DIR" 