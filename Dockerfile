# Use official Python image
FROM python:3.9-slim

# Set work directory
WORKDIR /app

# Copy project files into container
COPY . .

# Install dependencies if requirements.txt exists
RUN pip install --no-cache-dir -r requirements.txt || true

# Default command
CMD ["python3"]