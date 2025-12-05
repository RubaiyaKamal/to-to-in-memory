"""Main entry point for the todo application."""

import sys
from pathlib import Path

# Add src to path so imports work
src_path = Path(__file__).parent / "src"
sys.path.insert(0, str(src_path))

from todo.cli.app import main

if __name__ == "__main__":
    main()
