FROM python:3.11.12-alpine3.21

EXPOSE 5000

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=run.py

WORKDIR /app

COPY requirements.txt ./
RUN apk add --no-cache gcc musl-dev libffi-dev build-base && \
    pip install --no-cache-dir -r requirements.txt && \
    apk del gcc musl-dev libffi-dev build-base

COPY . .

CMD ["gunicorn", "run:app", "--bind", "0.0.0.0:5000"]