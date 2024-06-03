# Use the official Python base image
FROM python:3.12.3-slim-bookworm

# Set the working directory in the container
WORKDIR /app

# Copy the Poetry configuration files to the working directory
COPY database/pyproject.toml .

# Install Poetry
RUN pip install poetry

# Install project dependencies using Poetry
RUN poetry config virtualenvs.create false \
    && poetry install

# Copy the application code to the working directory
COPY database .

# Run the Flask server and checking for data directory and running make if necessary
CMD apt-get update && \
    apt-get install -y make wget && \
    if [ ! -d "data" ] || [ -z "$(ls -A data)" ]; then \
        echo "Running make..." && \
        make; \
    else \
        echo "Data directory exists and is not empty"; \
    fi && \
    python server.py