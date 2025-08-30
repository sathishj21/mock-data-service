"""Configuration management for the data service."""

import os
from pathlib import Path
from typing import Optional


class Config:
    """Application configuration."""
    
    # Data directory path - defaults to "data-docs" in current directory
    DATA_DIR: str = os.getenv("DATA_DIR", "data-docs")
    
    # File watching
    WATCH_FILE: bool = os.getenv("WATCH_FILE", "false").lower() == "true"
    
    # CORS settings
    ENABLE_CORS: bool = os.getenv("ENABLE_CORS", "false").lower() == "true"
    
    # Server settings
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))
    WORKERS: int = int(os.getenv("WORKERS", "2"))
    
    # File watching debounce (milliseconds)
    WATCH_DEBOUNCE_MS: int = int(os.getenv("WATCH_DEBOUNCE_MS", "500"))
    
    # Supported file extensions
    SUPPORTED_EXTENSIONS = {'.xlsx', '.xls', '.json', '.csv'}
    
    @classmethod
    def validate(cls) -> None:
        """Validate configuration and raise errors for missing required values."""
        data_dir = Path(cls.DATA_DIR)
        if not data_dir.exists():
            raise ValueError(f"Data directory not found: {cls.DATA_DIR}")
        
        if not data_dir.is_dir():
            raise ValueError(f"Data directory path is not a directory: {cls.DATA_DIR}")
        
        # Check if directory contains any supported files
        supported_files = cls.get_supported_files()
        if not supported_files:
            raise ValueError(f"No supported files found in directory: {cls.DATA_DIR}. Supported extensions: {cls.SUPPORTED_EXTENSIONS}")
    
    @classmethod
    def get_data_dir_path(cls) -> Path:
        """Get the data directory path as a Path object."""
        return Path(cls.DATA_DIR).resolve()
    
    @classmethod
    def get_supported_files(cls) -> list[Path]:
        """Get list of supported files in the data directory."""
        data_dir = cls.get_data_dir_path()
        supported_files = []
        
        for file_path in data_dir.iterdir():
            if file_path.is_file() and file_path.suffix.lower() in cls.SUPPORTED_EXTENSIONS:
                supported_files.append(file_path)
        
        return sorted(supported_files) 