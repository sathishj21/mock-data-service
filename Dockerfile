FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/

# Create data-docs directory and add data files
RUN mkdir -p /app/data-docs

# Create comprehensive sample data files
RUN echo '{\
  "employees": [\
    {"id": 1, "name": "John Doe", "department": "IT", "salary": 75000, "email": "john.doe@company.com"},\
    {"id": 2, "name": "Jane Smith", "department": "HR", "salary": 65000, "email": "jane.smith@company.com"},\
    {"id": 3, "name": "Bob Johnson", "department": "Sales", "salary": 70000, "email": "bob.johnson@company.com"},\
    {"id": 4, "name": "Alice Brown", "department": "Marketing", "salary": 68000, "email": "alice.brown@company.com"},\
    {"id": 5, "name": "Charlie Wilson", "department": "IT", "salary": 72000, "email": "charlie.wilson@company.com"}\
  ],\
  "departments": [\
    {"id": 1, "name": "IT", "location": "Floor 1", "manager": "John Doe"},\
    {"id": 2, "name": "HR", "location": "Floor 2", "manager": "Jane Smith"},\
    {"id": 3, "name": "Sales", "location": "Floor 3", "manager": "Bob Johnson"},\
    {"id": 4, "name": "Marketing", "location": "Floor 4", "manager": "Alice Brown"}\
  ],\
  "products": [\
    {"id": 1, "name": "Laptop", "category": "Electronics", "price": 999.99, "stock": 50},\
    {"id": 2, "name": "Mouse", "category": "Electronics", "price": 29.99, "stock": 100},\
    {"id": 3, "name": "Keyboard", "category": "Electronics", "price": 79.99, "stock": 75},\
    {"id": 4, "name": "Monitor", "category": "Electronics", "price": 299.99, "stock": 25}\
  ]\
}' > /app/data-docs/data.json

RUN echo 'id,name,department,salary,email\
1,John Doe,IT,75000,john.doe@company.com\
2,Jane Smith,HR,65000,jane.smith@company.com\
3,Bob Johnson,Sales,70000,bob.johnson@company.com\
4,Alice Brown,Marketing,68000,alice.brown@company.com\
5,Charlie Wilson,IT,72000,charlie.wilson@company.com' > /app/data-docs/data.csv

RUN echo 'id,name,category,price,stock\
1,Laptop,Electronics,999.99,50\
2,Mouse,Electronics,29.99,100\
3,Keyboard,Electronics,79.99,75\
4,Monitor,Electronics,299.99,25\
5,Headphones,Electronics,149.99,30' > /app/data-docs/products.csv

RUN echo 'id,name,department,salary,email\
1,John Doe,IT,75000,john.doe@company.com\
2,Jane Smith,HR,65000,jane.smith@company.com\
3,Bob Johnson,Sales,70000,bob.johnson@company.com\
4,Alice Brown,Marketing,68000,alice.brown@company.com\
5,Charlie Wilson,IT,72000,charlie.wilson@company.com' > /app/data-docs/sample_data.csv

# Verify data files were created
RUN ls -la /app/data-docs/ && echo "Data files created successfully"

# Expose port
EXPOSE 8000

# Set environment variables
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV DATA_DIR=/app/data-docs
ENV WATCH_FILE=false

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"] 