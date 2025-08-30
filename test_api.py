#!/usr/bin/env python3
"""Simple API test script."""

import os
import sys
import time
import subprocess
import requests
from pathlib import Path

def start_server():
    """Start the FastAPI server in the background."""
    print("🚀 Starting FastAPI server...")
    
    # Start server (no environment variables needed - defaults to data-docs)
    process = subprocess.Popen(
        [sys.executable, '-m', 'uvicorn', 'app.main:app', '--port', '8002', '--host', '127.0.0.1'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    
    # Wait for server to start
    time.sleep(3)
    
    return process

def test_health_endpoint():
    """Test the health endpoint."""
    print("Testing /health endpoint...")
    
    try:
        response = requests.get('http://127.0.0.1:8002/health', timeout=5)
        if response.status_code == 200:
            data = response.json()
            if data.get('status') == 'ok':
                print("✅ Health endpoint working")
                return True
            else:
                print(f"❌ Unexpected health response: {data}")
                return False
        else:
            print(f"❌ Health endpoint returned status {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health endpoint failed: {e}")
        return False

def test_datasets_endpoint():
    """Test the datasets endpoint."""
    print("Testing /datasets endpoint...")
    
    try:
        response = requests.get('http://127.0.0.1:8002/datasets', timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Datasets endpoint working")
            print(f"   - Source: {data.get('source', 'N/A')}")
            print(f"   - Type: {data.get('type', 'N/A')}")
            print(f"   - File count: {data.get('file_count', 'N/A')}")
            print(f"   - Datasets: {len(data.get('datasets', []))}")
            for dataset in data.get('datasets', []):
                print(f"     - {dataset.get('name')}: {dataset.get('records')} records")
            return True
        else:
            print(f"❌ Datasets endpoint returned status {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Datasets endpoint failed: {e}")
        return False

def test_data_endpoint():
    """Test the data endpoint."""
    print("Testing /data endpoint...")
    
    try:
        response = requests.get('http://127.0.0.1:8002/data', timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Data endpoint working")
            print(f"   - Keys: {list(data.keys())}")
            for key, value in data.items():
                if isinstance(value, list):
                    print(f"     - {key}: {len(value)} records")
                else:
                    print(f"     - {key}: {type(value)}")
            return True
        else:
            print(f"❌ Data endpoint returned status {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Data endpoint failed: {e}")
        return False

def test_single_dataset():
    """Test getting a single dataset."""
    print("Testing single dataset endpoint...")
    
    try:
        # Get available datasets first
        response = requests.get('http://127.0.0.1:8002/datasets', timeout=5)
        if response.status_code != 200:
            print(f"❌ Could not get datasets list: {response.status_code}")
            return False
        
        datasets_data = response.json()
        datasets = datasets_data.get('datasets', [])
        
        if not datasets:
            print("❌ No datasets available")
            return False
        
        # Test with the first available dataset
        first_dataset = datasets[0]['name']
        print(f"   - Testing with dataset: {first_dataset}")
        
        response = requests.get(f'http://127.0.0.1:8002/data?name={first_dataset}', timeout=5)
        if response.status_code == 200:
            data = response.json()
            if isinstance(data, list):
                print(f"✅ Single dataset endpoint working")
                print(f"   - Dataset: {first_dataset}")
                print(f"   - Records: {len(data)}")
                return True
            else:
                print(f"❌ Unexpected response format: {type(data)}")
                return False
        else:
            print(f"❌ Single dataset endpoint returned status {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Single dataset endpoint failed: {e}")
        return False

def main():
    """Run API tests."""
    print("🧪 Testing Data Service API (Directory-based)")
    print("=" * 50)
    
    # Start server
    server_process = start_server()
    
    try:
        # Run tests
        tests = [
            test_health_endpoint,
            test_datasets_endpoint,
            test_data_endpoint,
            test_single_dataset,
        ]
        
        passed = 0
        total = len(tests)
        
        for test in tests:
            try:
                if test():
                    passed += 1
                print()
            except Exception as e:
                print(f"❌ Test failed with exception: {e}")
                print()
        
        print("=" * 50)
        print(f"📊 API Test Results: {passed}/{total} tests passed")
        
        if passed == total:
            print("🎉 All API tests passed! The application is working correctly.")
            return 0
        else:
            print("⚠️  Some API tests failed. Check the output above for details.")
            return 1
            
    finally:
        # Stop server
        print("🛑 Stopping server...")
        server_process.terminate()
        server_process.wait()

if __name__ == "__main__":
    sys.exit(main()) 