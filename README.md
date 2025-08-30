# Data Service API

A production-ready FastAPI web service that reads local data files from a directory and exposes them via REST APIs.

## Features

- **Multiple File Formats**: Support for Excel (.xlsx, .xls), JSON (.json), and CSV (.csv) files
- **Directory-based Loading**: Automatically reads all supported files from a data directory
- **Flexible Data Structure**: 
  - Excel: Each sheet becomes a dataset (named as `filename_sheetname`)
  - JSON: Top-level object keys become datasets (named as `filename_key`), or top-level array becomes dataset named after file
  - CSV: Single dataset named after the file
- **RESTful API**: Clean, documented endpoints with OpenAPI/Swagger
- **Pagination**: Built-in pagination support with limit/offset
- **Caching**: ETag and Last-Modified headers for efficient caching
- **Hot Reload**: Optional file watching for automatic data reloading
- **Production Ready**: Gzip compression, CORS support, proper error handling
- **Comprehensive Testing**: Full test suite with pytest

## Quick Start

### Prerequisites

- Python 3.11+
- pip

### Installation

1. Clone or download the project
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Create sample data files:
   ```bash
   python3 create_samples.py
   ```

### Running Locally

#### Basic Usage

The application automatically reads from the `data-docs` directory by default:

```bash
# Run with default data-docs directory
uvicorn app.main:app --reload

# Run with custom data directory
DATA_DIR=./samples uvicorn app.main:app --reload
```

#### With File Watching (Hot Reload)

```bash
WATCH_FILE=true uvicorn app.main:app --reload
```

#### With CORS Enabled

```bash
ENABLE_CORS=true uvicorn app.main:app --reload
```

#### Production Mode

```bash
uvicorn app.main:app --workers 2 --host 0.0.0.0 --port 8000
```

### Docker

Build and run with Docker:

```bash
# Build the image
docker build -t data-service .

# Run with default data-docs directory
docker run -p 8000:8000 -v $(pwd)/data-docs:/app/data-docs data-service

# Run with custom data directory
docker run -p 8000:8000 -v $(pwd)/samples:/app/data-docs -e DATA_DIR=/app/data-docs data-service
```

## API Documentation

Once running, visit:
- **Interactive API docs**: http://localhost:8000/docs
- **ReDoc documentation**: http://localhost:8000/redoc

### Endpoints

#### `GET /health`
Health check endpoint.

**Response:**
```json
{
  "status": "ok"
}
```

#### `GET /datasets`
Get metadata about available datasets from all files in the data directory.

**Response:**
```json
{
  "source": "Directory with 3 files",
  "type": "multiple",
  "datasets": [
    {
      "name": "data_employees",
      "records": 50
    },
    {
      "name": "data_departments", 
      "records": 10
    },
    {
      "name": "mock_data_Use_Cases",
      "records": 22
    }
  ],
  "file_count": 3,
  "files": [
    {
      "path": "/path/to/data.json",
      "type": ".json",
      "last_modified": 1756474462.4053037,
      "size": 14854
    },
    {
      "path": "/path/to/data.xlsx",
      "type": ".xlsx",
      "last_modified": 1756474465.4027874,
      "size": 13190
    }
  ]
}
```

#### `GET /data`
Get data from datasets.

**Query Parameters:**
- `name` (optional, multiple): Dataset name(s) to retrieve
- `limit` (optional): Maximum number of records to return
- `offset` (optional): Number of records to skip

**Examples:**

```bash
# Get all datasets
GET /data

# Get specific dataset
GET /data?name=data_employees

# Get multiple datasets
GET /data?name=data_employees&name=data_departments

# Get with pagination
GET /data?name=data_employees&limit=50&offset=100

# Get multiple datasets with pagination
GET /data?name=data_employees&name=data_departments&limit=10
```

**Response Examples:**

Single dataset (no pagination):
```json
[
  {"id": 1, "name": "Employee 1", "department": "Dept 1"},
  {"id": 2, "name": "Employee 2", "department": "Dept 2"}
]
```

Multiple datasets:
```json
{
  "data_employees": [
    {"id": 1, "name": "Employee 1", "department": "Dept 1"}
  ],
  "data_departments": [
    {"id": 1, "name": "Department 1", "manager": "Manager 1"}
  ]
}
```

With pagination:
```json
{
  "data_employees": {
    "total": 200,
    "returned": 50,
    "data": [
      {"id": 101, "name": "Employee 101", "department": "Dept 1"}
    ]
  }
}
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DATA_DIR` | `data-docs` | Path to the data directory containing files |
| `WATCH_FILE` | `false` | Enable file watching for hot reload |
| `ENABLE_CORS` | `false` | Enable CORS headers |
| `HOST` | `0.0.0.0` | Server host |
| `PORT` | `8000` | Server port |
| `WORKERS` | `2` | Number of uvicorn workers |
| `WATCH_DEBOUNCE_MS` | `500` | File watch debounce in milliseconds |

### Data File Formats

#### Excel Files (.xlsx, .xls)
- Each worksheet becomes a dataset
- Dataset name format: `filename_sheetname`
- All data is converted to JSON-serializable format
- NaN values become `null`
- Datetimes become ISO 8601 strings

#### JSON Files (.json)
- **Top-level object**: Each key becomes a dataset name (format: `filename_key`)
  ```json
  {
    "employees": [...],
    "departments": [...]
  }
  ```
- **Top-level array**: Becomes a single dataset named after the file
  ```json
  [
    {"id": 1, "name": "Item 1"},
    {"id": 2, "name": "Item 2"}
  ]
  ```

#### CSV Files (.csv)
- Single dataset named after the file
- All data is converted to JSON-serializable format
- NaN values become `null`
- Datetimes become ISO 8601 strings

### Directory Structure

Place your data files in the `data-docs` directory (or your custom directory):

```
data-docs/
├── employees.xlsx      # Creates: employees_Sheet1, employees_Sheet2, etc.
├── departments.json    # Creates: departments_employees, departments_departments, etc.
├── products.csv        # Creates: products dataset
└── sales_data.xlsx     # Creates: sales_data_Sheet1, sales_data_Sheet2, etc.
```

## Error Handling

The API returns appropriate HTTP status codes and JSON error responses:

- **400 Bad Request**: Invalid parameters (negative limit/offset)
- **404 Not Found**: Dataset not found (includes list of available datasets)
- **415 Unsupported Media Type**: Unsupported file extension
- **500 Internal Server Error**: Unexpected errors

Error response format:
```json
{
  "error": "Dataset not found",
  "details": {
    "requested": ["NonExistent"],
    "available": ["data_employees", "data_departments"]
  }
}
```

## Testing

Run the test suite:

```bash
# Install test dependencies
pip install pytest httpx

# Run tests
pytest -v

# Run with coverage
pytest --cov=app tests/
```

The test suite covers:
- Directory-based file loading with multiple file types
- Excel file loading with multiple sheets
- JSON file loading (object and array formats)
- CSV file loading
- API endpoints and responses
- Pagination functionality
- Error handling
- Configuration validation

## Performance Features

- **Gzip Compression**: Automatic compression for responses > 1KB
- **Caching Headers**: ETag and Last-Modified headers for efficient caching
- **Thread-Safe**: Thread-safe data registry for concurrent access
- **Memory Efficient**: Data loaded once and shared across requests
- **Streaming**: Support for large datasets (FastAPI StreamingResponse ready)
- **Directory Watching**: Efficient file system monitoring for hot reload

## Security

- **Read-Only**: No file uploads, only reads from specified `DATA_DIR`
- **Path Isolation**: No filesystem access beyond the specified data directory
- **CORS Control**: Configurable CORS settings
- **Input Validation**: All parameters validated and sanitized
- **File Type Validation**: Only supported file extensions are processed

## Development

### Project Structure

```
data-service/
├── app/
│   ├── __init__.py
│   ├── main.py          # FastAPI application
│   ├── config.py        # Configuration management
│   ├── loader.py        # Data loading and registry
│   └── models.py        # Pydantic schemas
├── tests/
│   ├── __init__.py
│   └── test_app.py      # Unit tests
├── data-docs/           # Default data directory
│   ├── data.xlsx        # Sample Excel file
│   ├── data.json        # Sample JSON file
│   └── mock_data.xlsx   # Sample Excel file
├── samples/             # Additional sample files
│   ├── data.xlsx        # Sample Excel file
│   ├── data.json        # Sample JSON file
│   └── data_array.json  # Sample JSON array file
├── requirements.txt     # Python dependencies
├── Dockerfile          # Docker configuration
├── README.md           # This file
└── create_samples.py   # Sample data generator
```

### Adding New Features

1. **New File Format**: Extend `DataRegistry._load_*` methods in `loader.py`
2. **New Endpoint**: Add to `main.py` with proper error handling
3. **New Configuration**: Add to `Config` class in `config.py`
4. **Tests**: Add corresponding tests in `tests/test_app.py`

## License

This project is open source and available under the MIT License. 