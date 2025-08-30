#!/usr/bin/env python3
"""Script to create sample data files for testing."""

import json
import pandas as pd
import numpy as np
from datetime import datetime, timedelta

def create_excel_sample():
    """Create sample Excel file with multiple sheets."""
    # Create sample data for Employees sheet
    employees_data = {
        'id': list(range(1, 201)),
        'name': [f'Employee {i}' for i in range(1, 201)],
        'department': [f'Dept {(i % 5) + 1}' for i in range(1, 201)],
        'salary': np.random.randint(30000, 120000, 200).tolist(),
        'hire_date': pd.date_range('2020-01-01', periods=200, freq='D').tolist(),
        'is_active': [True if i % 10 != 0 else False for i in range(1, 201)]
    }

    # Create sample data for Departments sheet
    departments_data = {
        'id': list(range(1, 13)),
        'name': [f'Department {i}' for i in range(1, 13)],
        'manager': [f'Manager {i}' for i in range(1, 13)],
        'budget': np.random.randint(100000, 1000000, 12).tolist(),
        'created_date': pd.date_range('2019-01-01', periods=12, freq='M').tolist()
    }

    # Create DataFrame and save to Excel
    with pd.ExcelWriter('samples/data.xlsx', engine='openpyxl') as writer:
        pd.DataFrame(employees_data).to_excel(writer, sheet_name='Employees', index=False)
        pd.DataFrame(departments_data).to_excel(writer, sheet_name='Departments', index=False)

    print('Sample Excel file created: samples/data.xlsx')

def create_json_sample():
    """Create sample JSON file with multiple datasets."""
    # Create sample data
    employees = [
        {
            'id': i,
            'name': f'Employee {i}',
            'department': f'Dept {(i % 5) + 1}',
            'salary': np.random.randint(30000, 120000),
            'hire_date': (datetime.now() - timedelta(days=i*30)).isoformat(),
            'is_active': i % 10 != 0
        }
        for i in range(1, 51)  # 50 employees
    ]

    departments = [
        {
            'id': i,
            'name': f'Department {i}',
            'manager': f'Manager {i}',
            'budget': np.random.randint(100000, 1000000),
            'created_date': (datetime.now() - timedelta(days=i*90)).isoformat()
        }
        for i in range(1, 11)  # 10 departments
    ]

    products = [
        {
            'id': i,
            'name': f'Product {i}',
            'category': f'Category {(i % 3) + 1}',
            'price': round(np.random.uniform(10, 1000), 2),
            'in_stock': np.random.randint(0, 100)
        }
        for i in range(1, 31)  # 30 products
    ]

    # Create JSON structure with multiple datasets
    json_data = {
        'employees': employees,
        'departments': departments,
        'products': products
    }

    # Save to JSON file
    with open('samples/data.json', 'w') as f:
        json.dump(json_data, f, indent=2)

    print('Sample JSON file created: samples/data.json')

def create_json_array_sample():
    """Create sample JSON file with top-level array."""
    # Create sample data as array
    data = [
        {
            'id': i,
            'name': f'Item {i}',
            'category': f'Category {(i % 4) + 1}',
            'value': round(np.random.uniform(1, 100), 2),
            'created_at': (datetime.now() - timedelta(hours=i)).isoformat()
        }
        for i in range(1, 101)  # 100 items
    ]

    # Save to JSON file
    with open('samples/data_array.json', 'w') as f:
        json.dump(data, f, indent=2)

    print('Sample JSON array file created: samples/data_array.json')

if __name__ == '__main__':
    # Create samples directory if it doesn't exist
    import os
    os.makedirs('samples', exist_ok=True)
    
    create_excel_sample()
    create_json_sample()
    create_json_array_sample()
    print('All sample files created successfully!') 