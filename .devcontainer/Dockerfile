# Dockerfile for Weblate Dev Container (Self-Contained)

# Use a standard Python base image
FROM python:3.11-slim

# Set environment variables to prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    # Set paths for venv and uv cache within the container
    PATH="/app/venv/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    APP_HOME="/app" \
    VENV_PATH="/app/venv" \
    UV_CACHE_DIR="/app/uv-cache" \
    UV_LINK_MODE=copy \
    # Weblate specific settings (can be overridden by compose environment)
    DJANGO_SETTINGS_MODULE=weblate.settings_docker

WORKDIR ${APP_HOME}

# Arguments for user/group IDs (can be passed from docker-compose)
ARG USER_ID=1000
ARG GROUP_ID=1000

# Install system dependencies required by Weblate and its Python packages
# Based on weblate/dev-docker/weblate-dev/Dockerfile and common Python build needs
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Weblate runtime deps
    gettext \
    git \
    # Build dependencies for Python packages
    build-essential \
    pkg-config \
    gcc \
    # XML/Security
    libxml2-dev \
    libxmlsec1-dev \
    # Database clients (PostgreSQL needed for psycopg2 build)
    libpq-dev \
    # LDAP/SASL
    libsasl2-dev \
    libldap2-dev \
    # Image processing
    libjpeg62-turbo-dev \
    zlib1g-dev \
    # Other build deps found in original Dockerfile
    libcairo2-dev \
    libacl1-dev \
    liblz4-dev \
    libzstd-dev \
    libxxhash-dev \
    libmariadb-dev \
    libssl-dev \
    libffi-dev \
    libgirepository1.0-dev \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package installer/resolver)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Create a non-root user 'vscode' with specified IDs
# Give it sudo privileges if needed (optional, usually not required for dev containers)
RUN groupadd --gid ${GROUP_ID} vscode \
    && useradd --uid ${USER_ID} --gid ${GROUP_ID} --shell /bin/bash --create-home vscode \
    # Add user to sudo group if needed (requires installing sudo first)
    # && apt-get update && apt-get install -y sudo && echo vscode ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/vscode && chmod 0440 /etc/sudoers.d/vscode \
    && mkdir -p ${APP_HOME} ${VENV_PATH} ${UV_CACHE_DIR} \
    && chown -R ${USER_ID}:${GROUP_ID} ${APP_HOME}

# Copy the custom start script into the container
COPY --chown=vscode:vscode custom-start.sh /usr/local/bin/custom-start.sh
RUN chmod +x /usr/local/bin/custom-start.sh

# Switch to the non-root user
USER vscode

# Set the entrypoint to the custom start script
ENTRYPOINT ["/usr/local/bin/custom-start.sh"]

# Default command (can be overridden in docker-compose)
CMD ["runserver"]
