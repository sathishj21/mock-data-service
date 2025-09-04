"""Main FastAPI application."""

import logging
from typing import Any, Dict, List, Optional, Union
from datetime import datetime

from fastapi import FastAPI, HTTPException, Query, Response, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse

from .config import Config
from .loader import data_loader
from .models import (
    DatasetsResponse, DataResponse, ErrorResponse, HealthResponse,
    DatasetInfo, PaginatedData, ForecastDemandRequest, ForecastDemandResponse
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Data Service API",
    description="A FastAPI service that reads local data files and exposes them via REST APIs",
    version="1.0.0"
)

# Add middleware
app.add_middleware(GZipMiddleware, minimum_size=1000)

if Config.ENABLE_CORS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )


@app.on_event("startup")
async def startup_event():
    """Initialize the application on startup."""
    try:
        data_loader.initialize()
        logger.info("Data service started successfully")
    except Exception as e:
        logger.error(f"Failed to start data service: {e}")
        raise


@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown."""
    data_loader.shutdown()
    logger.info("Data service shutdown complete")


def _add_cache_headers(response: Response, etag: Optional[str] = None, last_modified: Optional[float] = None):
    """Add cache headers to response."""
    if etag:
        response.headers["ETag"] = etag
    if last_modified:
        response.headers["Last-Modified"] = datetime.fromtimestamp(last_modified).strftime('%a, %d %b %Y %H:%M:%S GMT')


@app.get("/health", response_model=HealthResponse, tags=["Health"])
async def health_check():
    """Health check endpoint."""
    return HealthResponse(status="ok")


@app.get("/datasets", response_model=DatasetsResponse, tags=["Data"])
async def get_datasets(response: Response):
    """Get metadata about available datasets from all files in the data directory."""
    try:
        registry = data_loader.registry
        file_info = registry.get_file_info()
        datasets_info = registry.get_datasets_info()
        
        # Add cache headers
        _add_cache_headers(
            response,
            etag=registry.get_etag(),
            last_modified=file_info.get("last_modified")
        )
        
        return DatasetsResponse(
            source=file_info["source"],
            type=file_info["type"],
            datasets=[DatasetInfo(**info) for info in datasets_info],
            file_count=file_info.get("file_count", 0),
            files=file_info.get("files", [])
        )
    except Exception as e:
        logger.error(f"Error in /datasets: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")


@app.get("/data", tags=["Data"])
async def get_data(
    response: Response,
    name: Optional[List[str]] = Query(None, description="Dataset name(s) to retrieve"),
    limit: Optional[int] = Query(None, ge=0, description="Maximum number of records to return"),
    offset: Optional[int] = Query(None, ge=0, description="Number of records to skip")
):
    """Get data from datasets."""
    try:
        registry = data_loader.registry
        available_names = registry.get_dataset_names()
        
        # Validate dataset names
        if name:
            invalid_names = [n for n in name if n not in available_names]
            if invalid_names:
                raise HTTPException(
                    status_code=404,
                    detail={
                        "error": "Dataset not found",
                        "details": {
                            "requested": invalid_names,
                            "available": available_names
                        }
                    }
                )
        
        # Validate pagination parameters
        if limit is not None and limit < 0:
            raise HTTPException(status_code=400, detail="Limit must be non-negative")
        if offset is not None and offset < 0:
            raise HTTPException(status_code=400, detail="Offset must be non-negative")
        
        # Determine which datasets to return
        if name:
            datasets_to_return = name
        else:
            datasets_to_return = available_names
        
        # Check if pagination is being used
        using_pagination = limit is not None or offset is not None
        
        # Get the data
        if len(datasets_to_return) == 1 and not using_pagination:
            # Single dataset, no pagination - return array directly
            dataset_name = datasets_to_return[0]
            data = registry.get_dataset(dataset_name)
            if data is None:
                raise HTTPException(status_code=404, detail="Dataset not found")
            
            result = data
        else:
            # Multiple datasets or using pagination - return dict
            result = {}
            for dataset_name in datasets_to_return:
                data = registry.get_dataset(dataset_name)
                if data is None:
                    continue
                
                if using_pagination:
                    # Apply pagination
                    total = len(data)
                    start = offset or 0
                    end = start + (limit or total)
                    paginated_data = data[start:end]
                    
                    result[dataset_name] = PaginatedData(
                        total=total,
                        returned=len(paginated_data),
                        data=paginated_data
                    )
                else:
                    # No pagination
                    result[dataset_name] = data
        
        # Add cache headers
        _add_cache_headers(
            response,
            etag=registry.get_etag(),
            last_modified=registry.get_file_info().get("last_modified")
        )
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in /data: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")


@app.post("/forecast_demand", response_model=ForecastDemandResponse, tags=["Forecast"])
async def forecast_demand(request: ForecastDemandRequest):
    """Forecast demand for specified product categories."""
    try:
        # Get the requested categories
        categories = [category.value for category in request.filters.product_category]
        
        # For now, return mock forecast data
        # In a real implementation, this would query your data and perform forecasting
        forecast_data = []
        
        for category in categories:
            # Mock forecast data for each category
            forecast_data.extend([
                {
                    "category": category,
                    "product_id": f"PROD_{category.upper().replace(' ', '_')}_001",
                    "forecasted_demand": 150,
                    "confidence_level": 0.85,
                    "forecast_date": "2024-01-15"
                },
                {
                    "category": category,
                    "product_id": f"PROD_{category.upper().replace(' ', '_')}_002", 
                    "forecasted_demand": 200,
                    "confidence_level": 0.92,
                    "forecast_date": "2024-01-15"
                }
            ])
        
        return ForecastDemandResponse(
            forecast_data=forecast_data,
            categories=categories,
            total_records=len(forecast_data)
        )
        
    except Exception as e:
        logger.error(f"Error in /forecast_demand: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")


@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    """Handle HTTP exceptions."""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": exc.detail.get("error", str(exc.detail)) if isinstance(exc.detail, dict) else str(exc.detail),
            "details": exc.detail.get("details") if isinstance(exc.detail, dict) else None
        }
    )


@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """Handle general exceptions."""
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal server error",
            "details": None
        }
    ) 