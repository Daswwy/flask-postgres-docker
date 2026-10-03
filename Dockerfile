FROM python:3.12-slim
WORKDIR /app
RUN pip install flask psycopg2-binary redis gunicorn prometheus_client
ENV PROMETHEUS_MULTIPROC_DIR=/tmp/prometheus
COPY app.py .
EXPOSE 5000 
CMD ["sh", "-c", "rm -rf /tmp/prometheus && mkdir -p /tmp/prometheus && exec gunicorn -w 2 -b 0.0.0.0:5000 --access-logfile - app:app"]
