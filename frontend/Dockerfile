FROM python:3.11-slim

WORKDIR /app

# Copy and install dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy application code
COPY . /app

EXPOSE 5000

CMD ["python", "/app/app.py"]
