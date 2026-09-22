FROM python:3.12-slim
WORKDIR /app
RUN pip install flask psycopg2-binary redis
COPY app.py .
EXPOSE 5000 
CMD ["python", "app.py"]
