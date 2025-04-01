# Weblate Development Environment with VS Code Dev Container

This project includes a configuration for using VS Code Dev Containers to provide a consistent and isolated development environment for Weblate.

## Features

*   **Consistent Environment:** Uses Docker to ensure all developers have the same environment setup.
*   **Persistent Python Environment:** Python dependencies (`/app/venv`) are stored in a Docker volume (`weblate_venv`), so they are installed only once on the first run, making subsequent starts much faster.
*   **Integrated Debugging:** Includes a VS Code launch configuration (`.vscode/launch.json`) to easily attach the debugger to the running Weblate application inside the container.
*   **Self-Contained:** Defines the entire environment (Dockerfile, Compose) within the `.devcontainer` folder, independent of other project directories.

## Prerequisites

*   [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running.
*   [Visual Studio Code](https://code.visualstudio.com/) installed.
*   [VS Code Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed.

## Getting Started

1.  **Clone the Repository:** If you haven't already, clone this project repository to your local machine.
2.  **Open in VS Code:** Open the root folder of the cloned repository (`path/to/your/project`) in VS Code.
3.  **Reopen in Container:** VS Code should automatically detect the `.devcontainer/devcontainer.json` configuration file. A notification will appear in the bottom-right corner asking if you want to "Reopen in Container". Click this button.
    *   **First Time:** The Dev Container image will be built (if necessary), and the container will be started. The `custom-start.sh` script will then run, creating the Python virtual environment and installing all dependencies from `pyproject.toml` into the persistent `/app/venv` volume. This initial setup might take several minutes depending on your system and network speed.
    *   **Subsequent Times:** Starting the container will be much faster as the dependencies are already installed in the persistent volume. The `custom-start.sh` script will detect this and skip the installation step.
4.  **Access Weblate:** Once the container is running and VS Code is connected, the Weblate development server will start automatically. You can typically access it in your web browser at `http://localhost:8080` (or the port specified by the `WEBLATE_PORT` environment variable if you have set one in `weblate/dev-docker/.env`).

## Debugging

1.  Ensure the Dev Container is running and VS Code is attached.
2.  Open the "Run and Debug" view in VS Code (usually accessible via the sidebar or by pressing `Ctrl+Shift+D`).
3.  Select **"Python: Attach to Weblate (Docker)"** from the configuration dropdown menu at the top.
4.  Click the green "Start Debugging" arrow (or press `F5`).
5.  The VS Code debugger will attach to the Weblate process running inside the container. You can now set breakpoints, inspect variables, step through code, etc., directly within VS Code.

## How it Works

*   The `.devcontainer/devcontainer.json` file tells VS Code how to build and manage the development container.
*   It uses Docker Compose with a self-contained configuration file: `.devcontainer/docker-compose.yml`.
*   The `.devcontainer/Dockerfile` defines the base image, system dependencies, and user setup.
*   The `.devcontainer/docker-compose.yml` file:
    *   Builds the `weblate` service using the `.devcontainer/Dockerfile`.
    *   Defines the `database` (PostgreSQL) and `cache` (Redis) services using standard images.
    *   Mounts the project root into `/workspaces` inside the container.
    *   Mounts named Docker volumes (`weblate_venv`, `weblate_uv_cache`, `postgres_data`, `redis_data`) for persistence.
    *   Sets `.devcontainer/custom-start.sh` as the entrypoint for the `weblate` service.
    *   Maps the necessary ports (application and debugging).
*   The `.devcontainer/custom-start.sh` script:
    *   Runs inside the `weblate` container.
    *   Checks if dependencies are already installed in the persistent `/app/venv` volume using a marker file (`.deps-installed`).
    *   If not installed, it creates the venv, installs dependencies from `pyproject.toml` (including `debugpy`), and creates the marker file.
    *   Starts the Weblate application using `python manage.py runserver` and `debugpy` (if the command is `runserver`), allowing the debugger to attach.
*   The `.vscode/launch.json` file configures the VS Code debugger to connect to the `debugpy` instance running on port `5678` inside the container.
