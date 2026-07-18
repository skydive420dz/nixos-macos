"""Minimal PyQt5 ApplicationContext implementation for the Nix package."""

import json
import os
import sys
from pathlib import Path

from PyQt5.QtWidgets import QApplication

from . import cached_property


class ApplicationContext:
    def __init__(self):
        # Vial and many Qt widgets assume a QApplication already exists.
        self.app

    @cached_property
    def app(self):
        app = QApplication(sys.argv)
        app.setApplicationName(self.build_settings["app_name"])
        app.setApplicationVersion(self.build_settings["version"])
        return app

    @cached_property
    def source_root(self):
        configured = os.environ.get("VIAL_SOURCE_ROOT")
        if configured:
            return Path(configured)
        return Path.cwd()

    @cached_property
    def build_settings(self):
        settings_path = self.source_root / "src" / "build" / "settings" / "base.json"
        with settings_path.open(encoding="utf-8") as settings_file:
            return json.load(settings_file)

    def get_resource(self, *relative_path):
        candidates = (
            self.source_root / "src" / "main" / "icons" / "mac",
            self.source_root / "src" / "main" / "icons" / "base",
            self.source_root / "src" / "main" / "resources" / "mac",
            self.source_root / "src" / "main" / "resources" / "base",
        )

        for directory in candidates:
            resource = directory.joinpath(*relative_path)
            if resource.exists():
                return str(resource.resolve())

        raise FileNotFoundError(
            f"Could not locate Vial resource: {'/'.join(relative_path)}"
        )
