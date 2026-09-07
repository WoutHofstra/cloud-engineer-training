# Set python as the base image
FROM python:3.12-slim

# Goes to /app as working directory
WORKDIR /app

# Copies requirements.txt into /app and installs them
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copies everything into /app
COPY . .

# Does not open a port on 5000! Purely informative 
EXPOSE 5000

# Runs app.py, equivalent to running 'python3 app.py'
CMD ["python", "app.py"]

