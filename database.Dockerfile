# Use the official Python base image
FROM python:3.12-slim-buster

# Set the working directory in the container
WORKDIR /app

# Copy the Poetry configuration files to the working directory
COPY database/pyproject.toml .

# Install Poetry
RUN pip install poetry

# Install project dependencies using Poetry
RUN poetry config virtualenvs.create false \
    && poetry install

RUN poetry add gunicorn
RUN poetry add uvicorn

# Copy the application code to the working directory
COPY database .

# Run the Flask server using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "server:app", "--worker-class", "uvicorn.workers.UvicornWorker", "--workers", "2"]