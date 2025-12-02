#!/usr/bin/env python3
"""
AirSpot Health - Launch Configuration Generator
This script generates VS Code launch configurations with environment variables from .env file
"""

import json
import os
from pathlib import Path


def load_env_file(env_path=".env"):
    """Load environment variables from .env file"""
    env_vars = {}
    if os.path.exists(env_path):
        with open(env_path, "r") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, value = line.split("=", 1)
                    env_vars[key.strip()] = value.strip()
    return env_vars


def generate_dart_defines(env_vars):
    """Generate --dart-define arguments from environment variables"""
    dart_defines = []
    for key, value in env_vars.items():
        dart_defines.append(f"--dart-define={key}={value}")
    return dart_defines


def create_launch_config(env_vars):
    """Create VS Code launch configuration"""
    dart_defines = generate_dart_defines(env_vars)

    config = {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "AirSpot Health (Debug with Env)",
                "type": "dart",
                "request": "launch",
                "program": "lib/main.dart",
                "args": dart_defines,
                "console": "debugConsole",
                "cwd": "${workspaceFolder}",
                "env": {"FLUTTER_WEB_AUTO_DETECT": "true"},
            },
            {
                "name": "AirSpot Health (Debug - No Env)",
                "type": "dart",
                "request": "launch",
                "program": "lib/main.dart",
                "console": "debugConsole",
                "cwd": "${workspaceFolder}",
                "env": {"FLUTTER_WEB_AUTO_DETECT": "true"},
            },
            {
                "name": "AirSpot Health (Profile with Env)",
                "type": "dart",
                "request": "launch",
                "program": "lib/main.dart",
                "args": dart_defines + ["--profile"],
                "console": "debugConsole",
                "cwd": "${workspaceFolder}",
                "env": {"FLUTTER_WEB_AUTO_DETECT": "true"},
            },
            {
                "name": "AirSpot Health (Release with Env)",
                "type": "dart",
                "request": "launch",
                "program": "lib/main.dart",
                "args": dart_defines + ["--release"],
                "console": "debugConsole",
                "cwd": "${workspaceFolder}",
                "env": {"FLUTTER_WEB_AUTO_DETECT": "true"},
            },
            {
                "name": "AirSpot Health (Android Debug with Env)",
                "type": "dart",
                "request": "launch",
                "program": "lib/main.dart",
                "args": dart_defines + ["-d", "android"],
                "console": "debugConsole",
                "cwd": "${workspaceFolder}",
                "env": {"FLUTTER_WEB_AUTO_DETECT": "true"},
            },
            {
                "name": "AirSpot Health (iOS Debug with Env)",
                "type": "dart",
                "request": "launch",
                "program": "lib/main.dart",
                "args": dart_defines + ["-d", "ios"],
                "console": "debugConsole",
                "cwd": "${workspaceFolder}",
                "env": {"FLUTTER_WEB_AUTO_DETECT": "true"},
            },
            {
                "name": "AirSpot Health (Web Debug with Env)",
                "type": "dart",
                "request": "launch",
                "program": "lib/main.dart",
                "args": dart_defines + ["-d", "web-server", "--web-port", "3000"],
                "console": "debugConsole",
                "cwd": "${workspaceFolder}",
                "env": {"FLUTTER_WEB_AUTO_DETECT": "true"},
            },
        ],
    }

    return config


def main():
    """Main function"""
    print("🚀 AirSpot Health - Launch Configuration Generator")

    # Load environment variables
    env_vars = load_env_file()

    if not env_vars:
        print("⚠️  No .env file found or no variables loaded")
        print("   Using default launch configuration without environment variables")
    else:
        print(f"✅ Loaded {len(env_vars)} environment variables from .env file")
        print("   Variables found:", ", ".join(env_vars.keys()))

    # Generate launch configuration
    config = create_launch_config(env_vars)

    # Write to .vscode/launch.json
    vscode_dir = Path(".vscode")
    vscode_dir.mkdir(exist_ok=True)

    launch_file = vscode_dir / "launch.json"
    with open(launch_file, "w") as f:
        json.dump(config, f, indent=2)

    print(f"✅ Launch configuration written to {launch_file}")
    print(
        "   You can now use VS Code's Run and Debug panel to launch the app with environment variables"
    )

    # Show available configurations
    print("\n📋 Available launch configurations:")
    for i, conf in enumerate(config["configurations"], 1):
        print(f"   {i}. {conf['name']}")


if __name__ == "__main__":
    main()
