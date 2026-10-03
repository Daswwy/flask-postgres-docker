FROM python:3.12-slim
WORKDIR /app
RUN pip install flask psycopg2-binary redis gunicorn
COPY app.py .
EXPOSE 5000 
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5000", "--access-logfile", "-", "app:app"]
