"""Data file loader and registry management."""

import json
import logging
import threading
import time
from pathlib import Path
from typing import Any, Dict, List, Optional, Union
from datetime import datetime

import pandas as pd
from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer

from .config import Config

logger = logging.getLogger(__name__)


class DataRegistry:
    """Thread-safe registry for loaded datasets from multiple files."""
    
    def __init__(self):
        self._lock = threading.RLock()
        self._datasets: Dict[str, List[Dict[str, Any]]] = {}
        self._file_info: Dict[str, Dict[str, Any]] = {}
        self._etag: Optional[str] = None
    
    def load_directory(self, directory_path: Path) -> None:
        """Load data from all supported files in directory and update registry."""
        with self._lock:
            try:
                logger.info(f"Loading data from directory: {directory_path}")
                
                # Clear existing data
                self._datasets.clear()
                self._file_info.clear()
                
                # Get all supported files
                supported_files = Config.get_supported_files()
                
                if not supported_files:
                    logger.warning(f"No supported files found in directory: {directory_path}")
                    return
                
                # Load each file
                for file_path in supported_files:
                    try:
                        self._load_single_file(file_path)
                    except Exception as e:
                        logger.error(f"Failed to load file {file_path}: {e}")
                        # Continue loading other files even if one fails
                
                self._update_etag()
                
                # Log dataset information
                total_records = sum(len(data) for data in self._datasets.values())
                logger.info(f"Loaded {len(self._datasets)} datasets with {total_records} total records from {len(self._file_info)} files")
                for name, data in self._datasets.items():
                    logger.info(f"  - {name}: {len(data)} records")
                    
            except Exception as e:
                logger.error(f"Failed to load data from directory {directory_path}: {e}")
                raise
    
    def _load_single_file(self, file_path: Path) -> None:
        """Load data from a single file."""
        logger.info(f"Loading file: {file_path}")
        
        # Detect file type
        suffix = file_path.suffix.lower()
        
        if suffix in ['.xlsx', '.xls']:
            self._load_excel(file_path)
        elif suffix == '.json':
            self._load_json(file_path)
        elif suffix == '.csv':
            self._load_csv(file_path)
        else:
            logger.warning(f"Unsupported file type: {suffix} for file {file_path}")
            return
        
        # Store file information
        self._file_info[str(file_path)] = {
            "path": str(file_path.resolve()),
            "type": suffix,
            "last_modified": file_path.stat().st_mtime,
            "size": file_path.stat().st_size
        }
    
    def _load_excel(self, file_path: Path) -> None:
        """Load Excel file with multiple sheets."""
        # Read all sheets
        excel_data = pd.read_excel(file_path, sheet_name=None)
        
        file_name = file_path.stem  # Get filename without extension
        
        for sheet_name, df in excel_data.items():
            # Create unique dataset name: filename_sheetname
            dataset_name = f"{file_name}_{sheet_name}"
            
            # Convert DataFrame to list of dicts, handling NaN values
            records = df.replace({pd.NA: None, pd.NaT: None}).to_dict(orient='records')
            
            # Convert datetime objects to ISO strings
            for record in records:
                for key, value in record.items():
                    if pd.isna(value):
                        record[key] = None
                    elif isinstance(value, (pd.Timestamp, datetime)):
                        record[key] = value.isoformat()
                    elif isinstance(value, (int, float)) and pd.isna(value):
                        record[key] = None
            
            self._datasets[dataset_name] = records
    
    def _load_json(self, file_path: Path) -> None:
        """Load JSON file."""
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        file_name = file_path.stem  # Get filename without extension
        
        if isinstance(data, dict):
            # Top-level object - each key is a dataset
            for key, value in data.items():
                if isinstance(value, list):
                    dataset_name = f"{file_name}_{key}"
                    self._datasets[dataset_name] = value
                else:
                    # Wrap scalar/object values in array for uniformity
                    dataset_name = f"{file_name}_{key}"
                    self._datasets[dataset_name] = [value]
        elif isinstance(data, list):
            # Top-level array - single dataset named after file
            self._datasets[file_name] = data
        else:
            raise ValueError("JSON file must contain either an object or an array")
    
    def _load_csv(self, file_path: Path) -> None:
        """Load CSV file."""
        df = pd.read_csv(file_path)
        
        file_name = file_path.stem  # Get filename without extension
        
        # Convert DataFrame to list of dicts, handling NaN values
        records = df.replace({pd.NA: None, pd.NaT: None}).to_dict(orient='records')
        
        # Convert datetime objects to ISO strings
        for record in records:
            for key, value in record.items():
                if pd.isna(value):
                    record[key] = None
                elif isinstance(value, (pd.Timestamp, datetime)):
                    record[key] = value.isoformat()
                elif isinstance(value, (int, float)) and pd.isna(value):
                    record[key] = None
        
        self._datasets[file_name] = records
    
    def _update_etag(self) -> None:
        """Update ETag based on file modification times and dataset signature."""
        if not self._file_info:
            self._etag = None
            return
        
        # Create a simple hash from file mtimes and dataset names
        file_signature = "|".join([
            f"{info['path']}:{info['last_modified']}" 
            for info in self._file_info.values()
        ])
        dataset_signature = "|".join(sorted(self._datasets.keys()))
        combined_signature = f"{file_signature}|{dataset_signature}"
        self._etag = f'"{hash(combined_signature)}"'
    
    def get_datasets_info(self) -> List[Dict[str, Any]]:
        """Get information about all datasets."""
        with self._lock:
            return [
                {"name": name, "records": len(data)}
                for name, data in self._datasets.items()
            ]
    
    def get_dataset(self, name: str) -> Optional[List[Dict[str, Any]]]:
        """Get a specific dataset by name."""
        with self._lock:
            return self._datasets.get(name)
    
    def get_datasets(self, names: List[str]) -> Dict[str, List[Dict[str, Any]]]:
        """Get multiple datasets by name."""
        with self._lock:
            return {name: self._datasets.get(name, []) for name in names}
    
    def get_all_datasets(self) -> Dict[str, List[Dict[str, Any]]]:
        """Get all datasets."""
        with self._lock:
            return self._datasets.copy()
    
    def get_file_info(self) -> Dict[str, Any]:
        """Get file information summary."""
        with self._lock:
            if not self._file_info:
                return {
                    "source": "No files loaded",
                    "type": "none",
                    "last_modified": None,
                    "file_count": 0
                }
            
            # Get the most recent modification time
            last_modified = max(info["last_modified"] for info in self._file_info.values())
            
            return {
                "source": f"Directory with {len(self._file_info)} files",
                "type": "multiple",
                "last_modified": last_modified,
                "file_count": len(self._file_info),
                "files": [
                    {
                        "path": info["path"],
                        "type": info["type"],
                        "last_modified": info["last_modified"],
                        "size": info["size"]
                    }
                    for info in self._file_info.values()
                ]
            }
    
    def get_etag(self) -> Optional[str]:
        """Get current ETag."""
        with self._lock:
            return self._etag
    
    def get_dataset_names(self) -> List[str]:
        """Get list of available dataset names."""
        with self._lock:
            return list(self._datasets.keys())


class DirectoryWatcher(FileSystemEventHandler):
    """Watch for file changes in directory and reload data."""
    
    def __init__(self, registry: DataRegistry, directory_path: Path):
        self.registry = registry
        self.directory_path = directory_path
        self.last_reload = 0
        self.debounce_ms = Config.WATCH_DEBOUNCE_MS
    
    def on_modified(self, event):
        """Handle file modification events."""
        if event.is_directory:
            return
        
        # Check if the modified file is in our watched directory
        try:
            file_path = Path(event.src_path)
            if file_path.parent != self.directory_path:
                return
            
            # Check if it's a supported file type
            if file_path.suffix.lower() not in Config.SUPPORTED_EXTENSIONS:
                return
        except Exception:
            return
        
        # Debounce reloads
        current_time = time.time() * 1000  # Convert to milliseconds
        if current_time - self.last_reload < self.debounce_ms:
            return
        
        self.last_reload = current_time
        
        try:
            logger.info(f"File changed in directory, reloading: {file_path}")
            self.registry.load_directory(self.directory_path)
        except Exception as e:
            logger.error(f"Failed to reload directory: {e}")
    
    def on_created(self, event):
        """Handle file creation events."""
        self.on_modified(event)
    
    def on_deleted(self, event):
        """Handle file deletion events."""
        self.on_modified(event)


class DataLoader:
    """Main data loader class."""
    
    def __init__(self):
        self.registry = DataRegistry()
        self.watcher: Optional[DirectoryWatcher] = None
        self.observer: Optional[Observer] = None
    
    def initialize(self) -> None:
        """Initialize the data loader."""
        # Validate configuration
        Config.validate()
        
        # Load initial data
        directory_path = Config.get_data_dir_path()
        self.registry.load_directory(directory_path)
        
        # Setup file watching if enabled
        if Config.WATCH_FILE:
            self._setup_file_watching(directory_path)
    
    def _setup_file_watching(self, directory_path: Path) -> None:
        """Setup file watching for hot reload."""
        try:
            self.watcher = DirectoryWatcher(self.registry, directory_path)
            self.observer = Observer()
            self.observer.schedule(self.watcher, str(directory_path), recursive=False)
            self.observer.start()
            logger.info(f"Directory watching enabled for: {directory_path}")
        except Exception as e:
            logger.error(f"Failed to setup directory watching: {e}")
    
    def shutdown(self) -> None:
        """Shutdown the data loader."""
        if self.observer:
            self.observer.stop()
            self.observer.join()
            logger.info("Directory watching stopped")


# Global instance
data_loader = DataLoader() 