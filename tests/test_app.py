"""Unit tests for the data service application."""

import json
import os
import tempfile
import pytest
from pathlib import Path
from unittest.mock import patch, MagicMock

from fastapi.testclient import TestClient

from app.main import app
from app.config import Config
from app.loader import DataRegistry, DataLoader


@pytest.fixture
def client():
    """Create a test client."""
    return TestClient(app)


@pytest.fixture
def temp_excel_file():
    """Create a temporary Excel file for testing."""
    import pandas as pd
    import numpy as np
    
    # Create sample data
    employees_data = {
        'id': list(range(1, 11)),
        'name': [f'Employee {i}' for i in range(1, 11)],
        'department': [f'Dept {(i % 3) + 1}' for i in range(1, 11)],
        'salary': np.random.randint(30000, 120000, 10).tolist(),
    }
    
    departments_data = {
        'id': list(range(1, 4)),
        'name': [f'Department {i}' for i in range(1, 4)],
        'manager': [f'Manager {i}' for i in range(1, 4)],
    }
    
    with tempfile.NamedTemporaryFile(suffix='.xlsx', delete=False) as tmp:
        with pd.ExcelWriter(tmp.name, engine='openpyxl') as writer:
            pd.DataFrame(employees_data).to_excel(writer, sheet_name='Employees', index=False)
            pd.DataFrame(departments_data).to_excel(writer, sheet_name='Departments', index=False)
        yield tmp.name
    
    os.unlink(tmp.name)


@pytest.fixture
def temp_json_file():
    """Create a temporary JSON file for testing."""
    data = {
        'employees': [
            {'id': 1, 'name': 'John Doe', 'department': 'IT'},
            {'id': 2, 'name': 'Jane Smith', 'department': 'HR'},
        ],
        'departments': [
            {'id': 1, 'name': 'IT', 'manager': 'Bob'},
            {'id': 2, 'name': 'HR', 'manager': 'Alice'},
        ]
    }
    
    with tempfile.NamedTemporaryFile(suffix='.json', delete=False, mode='w') as tmp:
        json.dump(data, tmp)
        yield tmp.name
    
    os.unlink(tmp.name)


@pytest.fixture
def temp_json_array_file():
    """Create a temporary JSON array file for testing."""
    data = [
        {'id': 1, 'name': 'Item 1', 'value': 10.5},
        {'id': 2, 'name': 'Item 2', 'value': 20.3},
        {'id': 3, 'name': 'Item 3', 'value': 15.7},
    ]
    
    with tempfile.NamedTemporaryFile(suffix='.json', delete=False, mode='w') as tmp:
        json.dump(data, tmp)
        yield tmp.name
    
    os.unlink(tmp.name)


class TestDataRegistry:
    """Test the DataRegistry class."""
    
    def test_load_excel_file(self, temp_excel_file):
        """Test loading Excel file with multiple sheets."""
        registry = DataRegistry()
        registry.load_file(Path(temp_excel_file))
        
        # Check that both sheets are loaded
        assert 'Employees' in registry._datasets
        assert 'Departments' in registry._datasets
        
        # Check data
        employees = registry.get_dataset('Employees')
        assert len(employees) == 10
        assert employees[0]['name'] == 'Employee 1'
        
        departments = registry.get_dataset('Departments')
        assert len(departments) == 3
        assert departments[0]['name'] == 'Department 1'
    
    def test_load_json_file(self, temp_json_file):
        """Test loading JSON file with multiple datasets."""
        registry = DataRegistry()
        registry.load_file(Path(temp_json_file))
        
        # Check that both datasets are loaded
        assert 'employees' in registry._datasets
        assert 'departments' in registry._datasets
        
        # Check data
        employees = registry.get_dataset('employees')
        assert len(employees) == 2
        assert employees[0]['name'] == 'John Doe'
        
        departments = registry.get_dataset('departments')
        assert len(departments) == 2
        assert departments[0]['name'] == 'IT'
    
    def test_load_json_array_file(self, temp_json_array_file):
        """Test loading JSON file with top-level array."""
        registry = DataRegistry()
        registry.load_file(Path(temp_json_array_file))
        
        # Check that array is loaded as 'data' dataset
        assert 'data' in registry._datasets
        
        # Check data
        data = registry.get_dataset('data')
        assert len(data) == 3
        assert data[0]['name'] == 'Item 1'
    
    def test_get_datasets_info(self, temp_excel_file):
        """Test getting datasets information."""
        registry = DataRegistry()
        registry.load_file(Path(temp_excel_file))
        
        info = registry.get_datasets_info()
        assert len(info) == 2
        
        # Find Employees dataset info
        employees_info = next(i for i in info if i['name'] == 'Employees')
        assert employees_info['records'] == 10
        
        # Find Departments dataset info
        departments_info = next(i for i in info if i['name'] == 'Departments')
        assert departments_info['records'] == 3
    
    def test_get_multiple_datasets(self, temp_excel_file):
        """Test getting multiple datasets."""
        registry = DataRegistry()
        registry.load_file(Path(temp_excel_file))
        
        datasets = registry.get_datasets(['Employees', 'Departments'])
        assert 'Employees' in datasets
        assert 'Departments' in datasets
        assert len(datasets['Employees']) == 10
        assert len(datasets['Departments']) == 3


class TestAPIEndpoints:
    """Test the API endpoints."""
    
    @patch('app.main.data_loader')
    def test_health_endpoint(self, mock_data_loader, client):
        """Test health check endpoint."""
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json() == {"status": "ok"}
    
    @patch('app.main.data_loader')
    def test_datasets_endpoint(self, mock_data_loader, client, temp_excel_file):
        """Test datasets endpoint."""
        # Setup mock
        registry = DataRegistry()
        registry.load_file(Path(temp_excel_file))
        mock_data_loader.registry = registry
        
        response = client.get("/datasets")
        assert response.status_code == 200
        
        data = response.json()
        assert data['type'] == 'excel'
        assert data['source'] == str(Path(temp_excel_file).resolve())
        assert len(data['datasets']) == 2
        
        # Check dataset names
        dataset_names = [d['name'] for d in data['datasets']]
        assert 'Employees' in dataset_names
        assert 'Departments' in dataset_names
    
    @patch('app.main.data_loader')
    def test_data_endpoint_all_datasets(self, mock_data_loader, client, temp_excel_file):
        """Test data endpoint returning all datasets."""
        # Setup mock
        registry = DataRegistry()
        registry.load_file(Path(temp_excel_file))
        mock_data_loader.registry = registry
        
        response = client.get("/data")
        assert response.status_code == 200
        
        data = response.json()
        assert 'Employees' in data
        assert 'Departments' in data
        assert len(data['Employees']) == 10
        assert len(data['Departments']) == 3
    
    @patch('app.main.data_loader')
    def test_data_endpoint_single_dataset(self, mock_data_loader, client, temp_excel_file):
        """Test data endpoint returning single dataset."""
        # Setup mock
        registry = DataRegistry()
        registry.load_file(Path(temp_excel_file))
        mock_data_loader.registry = registry
        
        response = client.get("/data?name=Employees")
        assert response.status_code == 200
        
        data = response.json()
        # Should return array directly for single dataset
        assert isinstance(data, list)
        assert len(data) == 10
        assert data[0]['name'] == 'Employee 1'
    
    @patch('app.main.data_loader')
    def test_data_endpoint_multiple_datasets(self, mock_data_loader, client, temp_excel_file):
        """Test data endpoint returning multiple specific datasets."""
        # Setup mock
        registry = DataRegistry()
        registry.load_file(Path(temp_excel_file))
        mock_data_loader.registry = registry
        
        response = client.get("/data?name=Employees&name=Departments")
        assert response.status_code == 200
        
        data = response.json()
        assert 'Employees' in data
        assert 'Departments' in data
        assert len(data['Employees']) == 10
        assert len(data['Departments']) == 3
    
    @patch('app.main.data_loader')
    def test_data_endpoint_pagination(self, mock_data_loader, client, temp_excel_file):
        """Test data endpoint with pagination."""
        # Setup mock
        registry = DataRegistry()
        registry.load_file(Path(temp_excel_file))
        mock_data_loader.registry = registry
        
        response = client.get("/data?name=Employees&limit=5&offset=2")
        assert response.status_code == 200
        
        data = response.json()
        assert 'Employees' in data
        employees_data = data['Employees']
        
        # Should have pagination wrapper
        assert 'total' in employees_data
        assert 'returned' in employees_data
        assert 'data' in employees_data
        
        assert employees_data['total'] == 10
        assert employees_data['returned'] == 5
        assert len(employees_data['data']) == 5
        # Should start from offset 2
        assert employees_data['data'][0]['name'] == 'Employee 3'
    
    @patch('app.main.data_loader')
    def test_data_endpoint_dataset_not_found(self, mock_data_loader, client, temp_excel_file):
        """Test data endpoint with non-existent dataset."""
        # Setup mock
        registry = DataRegistry()
        registry.load_file(Path(temp_excel_file))
        mock_data_loader.registry = registry
        
        response = client.get("/data?name=NonExistent")
        assert response.status_code == 404
        
        data = response.json()
        assert 'error' in data
        assert 'details' in data
        assert 'NonExistent' in data['details']['requested']
        assert 'Employees' in data['details']['available']
        assert 'Departments' in data['details']['available']
    
    @patch('app.main.data_loader')
    def test_data_endpoint_invalid_pagination(self, mock_data_loader, client, temp_excel_file):
        """Test data endpoint with invalid pagination parameters."""
        # Setup mock
        registry = DataRegistry()
        registry.load_file(Path(temp_excel_file))
        mock_data_loader.registry = registry
        
        # Test negative limit
        response = client.get("/data?limit=-1")
        assert response.status_code == 400
        
        # Test negative offset
        response = client.get("/data?offset=-1")
        assert response.status_code == 400


class TestConfiguration:
    """Test configuration validation."""
    
    def test_validate_missing_data_file(self):
        """Test validation with missing DATA_FILE."""
        with patch.dict(os.environ, {}, clear=True):
            with pytest.raises(ValueError, match="DATA_FILE environment variable is required"):
                Config.validate()
    
    def test_validate_nonexistent_file(self):
        """Test validation with non-existent file."""
        with patch.dict(os.environ, {'DATA_FILE': '/nonexistent/file.xlsx'}, clear=True):
            with pytest.raises(ValueError, match="Data file not found"):
                Config.validate()
    
    def test_validate_unsupported_file_type(self):
        """Test validation with unsupported file type."""
        with tempfile.NamedTemporaryFile(suffix='.txt', delete=False) as tmp:
            with patch.dict(os.environ, {'DATA_FILE': tmp.name}, clear=True):
                with pytest.raises(ValueError, match="Unsupported file type"):
                    Config.validate()
            os.unlink(tmp.name)


class TestErrorHandling:
    """Test error handling."""
    
    @patch('app.main.data_loader')
    def test_internal_server_error(self, mock_data_loader, client):
        """Test internal server error handling."""
        # Make the registry raise an exception
        mock_data_loader.registry.get_file_info.side_effect = Exception("Test error")
        
        response = client.get("/datasets")
        assert response.status_code == 500
        
        data = response.json()
        assert data['error'] == 'Internal server error' 