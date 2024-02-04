# Use an official Python runtime as a parent image
FROM python:3.10-buster

# Install ffmpeg
RUN apt-get update && apt-get install -y ffmpeg

# Install system dependencies
RUN apt-get install -y \
    gcc \
    python3-dev \
    libevent-dev \
    libffi-dev \
    musl-dev \
    python3-gevent

# Upgrade pip
RUN pip install --upgrade pip

# Set the working directory in the container to /app
WORKDIR /app

# Copy only requirements.txt first to leverage Docker cache
COPY ./requirements.txt /app/requirements.txt

# Install Python packages
RUN pip install -r /app/requirements.txt

# Download the spacy model
RUN python -m spacy download en_core_web_sm

# Copy the rest of the application
COPY . /app

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Run app.py when the container launches
#CMD ["gunicorn", "-b", "0.0.0.0:5000", "main:app"]
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "main:app", "-k", "gthread"]
#CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5000", "main:app", "--timeout", "900"]
#CMD ["gunicorn", "-b", "0.0.0.0:5000", "-k", "geventwebsocket.gunicorn.workers.GeventWebSocketWorker", "-w", "1", "main:app"]
