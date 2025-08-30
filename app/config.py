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
        import logging
        logger = logging.getLogger(__name__)
        
        # Debug information
        logger.info(f"Current working directory: {os.getcwd()}")
        logger.info(f"DATA_DIR environment variable: {os.getenv('DATA_DIR')}")
        logger.info(f"DATA_DIR resolved: {cls.DATA_DIR}")
        
        data_dir = Path(cls.DATA_DIR)
        logger.info(f"Data directory path: {data_dir}")
        logger.info(f"Data directory absolute path: {data_dir.resolve()}")
        logger.info(f"Data directory exists: {data_dir.exists()}")
        
        if not data_dir.exists():
            logger.error(f"Data directory not found: {cls.DATA_DIR}")
            raise ValueError(f"Data directory not found: {cls.DATA_DIR}")
        
        if not data_dir.is_dir():
            logger.error(f"Data directory path is not a directory: {cls.DATA_DIR}")
            raise ValueError(f"Data directory path is not a directory: {cls.DATA_DIR}")
        
        # List all files in the directory for debugging
        logger.info(f"All files in {data_dir}:")
        try:
            for item in data_dir.iterdir():
                logger.info(f"  - {item.name} ({'dir' if item.is_dir() else 'file'})")
        except Exception as e:
            logger.error(f"Error listing directory contents: {e}")
        
        # Check if directory contains any supported files
        supported_files = cls.get_supported_files()
        logger.info(f"Supported files found: {len(supported_files)}")
        for file in supported_files:
            logger.info(f"  - {file.name}")
        
        if not supported_files:
            logger.error(f"No supported files found in directory: {cls.DATA_DIR}. Supported extensions: {cls.SUPPORTED_EXTENSIONS}")
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