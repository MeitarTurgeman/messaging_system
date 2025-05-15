FROM python:3.11.12-alpine3.21

EXPOSE 5000

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=run.py

COPY requirements.txt /app/
COPY . /app/
RUN pip install --no-cache-dir -r requirements.txt

WORKDIR /app

CMD ["python", "run.py"]