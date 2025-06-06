FROM python:3.11.12-alpine3.21

# Install required system packages and psycopg2 dependencies
RUN apk add --no-cache \
    libpq \
    gcc \
    musl-dev \
    libffi-dev \
    postgresql-dev \
    build-base

WORKDIR /app

COPY requirements.txt ./

# Install python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Remove build packages to keep the image small
RUN apk del gcc musl-dev libffi-dev build-base postgresql-dev

COPY . .

EXPOSE 5000

# For Flask auto-reload in development, you can override the CMD in docker-compose (not here)
CMD ["gunicorn", "run:app", "--bind", "0.0.0.0:5000", "--workers=3"]