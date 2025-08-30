"""Pydantic models for API schemas."""

from typing import Any, Dict, List, Optional, Union
from pydantic import BaseModel, Field, RootModel


class DatasetInfo(BaseModel):
    """Information about a dataset."""
    name: str = Field(..., description="Dataset name (filename_sheetname or filename_key)")
    records: int = Field(..., description="Number of records in the dataset")


class FileInfo(BaseModel):
    """Information about a data file."""
    path: str = Field(..., description="Absolute path to the file")
    type: str = Field(..., description="File type: 'xlsx', 'xls', 'json', or 'csv'")
    last_modified: float = Field(..., description="Last modification timestamp")
    size: int = Field(..., description="File size in bytes")


class DatasetsResponse(BaseModel):
    """Response for /datasets endpoint."""
    source: str = Field(..., description="Description of the data source")
    type: str = Field(..., description="Source type: 'multiple' for directory, 'excel' or 'json' for single file")
    datasets: List[DatasetInfo] = Field(..., description="List of available datasets")
    file_count: int = Field(..., description="Number of files loaded")
    files: List[FileInfo] = Field(..., description="List of loaded files")


class PaginatedData(BaseModel):
    """Paginated data wrapper."""
    total: int = Field(..., description="Total number of records")
    returned: int = Field(..., description="Number of records returned")
    data: List[Dict[str, Any]] = Field(..., description="The actual data records")


class DataResponse(RootModel):
    """Response for /data endpoint."""
    # This is a flexible model that can represent either:
    # - Direct array when single dataset requested
    # - Dict of dataset names to data when multiple datasets requested
    # - Dict of dataset names to PaginatedData when pagination is used
    root: Union[
        List[Dict[str, Any]],  # Single dataset, no pagination
        Dict[str, List[Dict[str, Any]]],  # Multiple datasets, no pagination
        Dict[str, PaginatedData]  # Multiple datasets with pagination
    ]


class ErrorResponse(BaseModel):
    """Error response model."""
    error: str = Field(..., description="Error message")
    details: Optional[Dict[str, Any]] = Field(None, description="Additional error details")


class HealthResponse(BaseModel):
    """Health check response."""
    status: str = Field(..., description="Service status") 