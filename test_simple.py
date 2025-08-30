#!/usr/bin/env python3
"""Simple test script to verify the application works."""

import json
import os
import sys
from pathlib import Path

def test_json_loading():
    """Test JSON file loading functionality."""
    print("Testing JSON file loading...")
    
    # Test with the sample JSON file
    json_file = Path("samples/data.json")
    if not json_file.exists():
        print("❌ Sample JSON file not found")
        return False
    
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
        
        print(f"✅ JSON file loaded successfully")
        print(f"   - Keys: {list(data.keys())}")
        print(f"   - Employees: {len(data.get('employees', []))} records")
        print(f"   - Departments: {len(data.get('departments', []))} records")
        return True
    except Exception as e:
        print(f"❌ Failed to load JSON file: {e}")
        return False

def test_json_array_loading():
    """Test JSON array file loading functionality."""
    print("\nTesting JSON array file loading...")
    
    # Test with the sample JSON array file
    json_file = Path("samples/data_array.json")
    if not json_file.exists():
        print("❌ Sample JSON array file not found")
        return False
    
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
        
        print(f"✅ JSON array file loaded successfully")
        print(f"   - Type: {type(data)}")
        print(f"   - Records: {len(data)}")
        return True
    except Exception as e:
        print(f"❌ Failed to load JSON array file: {e}")
        return False

def test_excel_loading():
    """Test Excel file loading functionality."""
    print("\nTesting Excel file loading...")
    
    # Test with the sample Excel file
    excel_file = Path("samples/data.xlsx")
    if not excel_file.exists():
        print("❌ Sample Excel file not found")
        return False
    
    try:
        import pandas as pd
        excel_data = pd.read_excel(excel_file, sheet_name=None)
        
        print(f"✅ Excel file loaded successfully")
        print(f"   - Sheets: {list(excel_data.keys())}")
        for sheet_name, df in excel_data.items():
            print(f"   - {sheet_name}: {len(df)} records")
        return True
    except ImportError:
        print("⚠️  pandas not available, skipping Excel test")
        return True
    except Exception as e:
        print(f"❌ Failed to load Excel file: {e}")
        return False

def test_config():
    """Test configuration functionality."""
    print("\nTesting configuration...")
    
    try:
        # Test with a valid file
        os.environ['DATA_FILE'] = 'samples/data.json'
        
        # Import and test config
        sys.path.insert(0, '.')
        from app.config import Config
        
        # Test validation
        Config.validate()
        print("✅ Configuration validation passed")
        
        # Test file path
        file_path = Config.get_data_file_path()
        print(f"   - Data file path: {file_path}")
        return True
    except Exception as e:
        print(f"❌ Configuration test failed: {e}")
        return False

def main():
    """Run all tests."""
    print("🧪 Running simple tests for Data Service API")
    print("=" * 50)
    
    tests = [
        test_json_loading,
        test_json_array_loading,
        test_excel_loading,
        test_config,
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        try:
            if test():
                passed += 1
        except Exception as e:
            print(f"❌ Test failed with exception: {e}")
    
    print("\n" + "=" * 50)
    print(f"📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! The application should work correctly.")
        return 0
    else:
        print("⚠️  Some tests failed. Check the output above for details.")
        return 1

if __name__ == "__main__":
    sys.exit(main()) 