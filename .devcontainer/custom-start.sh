#!/bin/sh

# Custom start script for Weblate Dev Container (Self-Contained)
# Handles persistent venv and enables debugging

set -e

MARKER_FILE="/app/venv/.deps-installed"
VENV_PATH="/app/venv"
# Project root is mounted at /workspaces, Weblate source is in /workspaces/weblate
WEBLATE_SRC_PATH="/workspaces/weblate"

# Ensure we are in the Weblate source directory
cd "${WEBLATE_SRC_PATH}"

# Check if dependencies are already installed (marker file exists)
if [ ! -f "${MARKER_FILE}" ]; then
    echo ">>> First time setup: Installing dependencies in persistent venv (${VENV_PATH})..."

    echo "Creating/Updating virtual environment (${VENV_PATH})..."
    # Ensure venv exists, uv venv handles creation/update
    uv venv --python python3 "${VENV_PATH}"

    # Activate the virtual environment
    # shellcheck disable=SC1091
    . "${VENV_PATH}/bin/activate"

    echo "Installing Weblate requirements from pyproject.toml and debugpy..."
    # Install dependencies using uv pip sync or install based on pyproject.toml
    # Using 'sync' ensures the environment matches the lock file if present,
    # otherwise 'pip install -e .' installs the project in editable mode with deps.
    # Let's use install -e . for development setup.
    uv pip install --no-config -e .[all] # Install project editable with all extras
    uv pip install --no-config debugpy~=1.8 # Install debugger separately

    # Check if installation was successful before creating marker
    if [ $? -eq 0 ]; then
        echo "Dependencies installed successfully."
        # Create marker file to indicate successful installation
        touch "${MARKER_FILE}"
    else
        echo "Error: Dependency installation failed."
        # Optionally remove potentially corrupted venv?
        # rm -rf "${VENV_PATH}"
        exit 1
    fi

else
    echo ">>> Dependencies already installed in ${VENV_PATH}, skipping installation."
    # Activate the existing virtual environment
    # shellcheck disable=SC1091
    . "${VENV_PATH}/bin/activate"
fi

echo "Starting Weblate..."

# Check if the command is 'runserver' (default or passed) to enable debugging
# Default CMD is runserver, but allow overriding via compose 'command'
COMMAND=${1:-runserver} # Default to runserver if no args passed

if [ "$COMMAND" = "runserver" ]; then
    echo ">>> Starting Weblate with debugging enabled on port 5678..."
    # Use exec to replace the shell process
    # Use --noreload for stable debugging
    # Listen on 0.0.0.0 inside the container
    # Default port 8080 is mapped by compose
    exec python -m debugpy --listen 0.0.0.0:5678 manage.py runserver --noreload 0.0.0.0:8080
else
    echo ">>> Starting Weblate with command: python manage.py $*"
    # Execute manage.py with the provided command and arguments
    exec python manage.py "$@"
fi
