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

CMD apt-get update && \
    apt-get install -y make wget && \
    if [ ! -d "data" ] || [ -z "$(ls -A data)" ]; then \
        make; \
    fi && \
    python server.py