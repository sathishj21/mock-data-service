#!/bin/bash

echo "🧪 Simple Render Build Test"
echo "=========================="

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
echo "Created temp directory: $TEMP_DIR"

# Copy app files
cp -r app/ $TEMP_DIR/
cp requirements.txt $TEMP_DIR/

cd $TEMP_DIR

echo "Current directory: $(pwd)"
echo "Files:"
ls -la

# Create data-docs directory
mkdir -p data-docs

# Create sample data files (same as render.yaml)
echo "Creating sample data files..."

cat > data-docs/data.json << 'EOF'
{
  "employees": [
    {"id": 1, "name": "John Doe", "department": "IT", "salary": 75000, "email": "john.doe@company.com"},
    {"id": 2, "name": "Jane Smith", "department": "HR", "salary": 65000, "email": "jane.smith@company.com"},
    {"id": 3, "name": "Bob Johnson", "department": "Sales", "salary": 70000, "email": "bob.johnson@company.com"}
  ]
}
EOF

cat > data-docs/data.csv << 'EOF'
id,name,department,salary,email
1,John Doe,IT,75000,john.doe@company.com
2,Jane Smith,HR,65000,jane.smith@company.com
3,Bob Johnson,Sales,70000,bob.johnson@company.com
EOF

echo "Data files created:"
ls -la data-docs/
echo "File sizes:"
du -h data-docs/*

echo "✅ Build test completed successfully!"

# Clean up
cd /Users/satkotee/projects/ps/retail-data-service
rm -rf $TEMP_DIR 