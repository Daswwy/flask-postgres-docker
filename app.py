import time
from flask import request, Response
from prometheus_client import (Counter, Histogram, CollectorRegistry,
                               multiprocess, generate_latest, CONTENT_TYPE_LATEST)
import os	
from flask import Flask
import psycopg2
import redis

app = Flask(__name__)

REQUESTS = Counter('http_requests_total', 'Total HTTP requests',
                   ['method', 'endpoint', 'status'])
LATENCY = Histogram('http_request_duration_seconds', 'Request latency',
                    ['endpoint'])

@app.before_request
def start_timer():
    request.start_time = time.time()

@app.after_request
def record_metrics(response):
    if request.path != '/metrics':
        endpoint = request.url_rule.rule if request.url_rule else 'unknown'
        LATENCY.labels(endpoint).observe(time.time() - request.start_time)
        REQUESTS.labels(request.method, endpoint, response.status_code).inc()
    return response

@app.route('/metrics')
def metrics():
    registry = CollectorRegistry()
    multiprocess.MultiProcessCollector(registry)
    return Response(generate_latest(registry), mimetype=CONTENT_TYPE_LATEST)

@app.route('/health')
def health():
    try:
        conn = psycopg2.connect(host=os.environ.get('POSTGRES_HOST', 'db'),
                                database=os.environ['POSTGRES_DB'],
                                user=os.environ['POSTGRES_USER'],
                                password=os.environ['POSTGRES_PASSWORD'],
                                connect_timeout=2)
        conn.close()
        r.ping()
        return {'status': 'ok'}, 200
    except Exception as e:
        return {'status': 'error', 'detail': str(e)}, 503


r = redis.Redis(host='redis', port=6379, decode_responses=True)

@app.route('/')
def home():
	return '<h1>Docker+Flask test)</h1>'

@app.route('/about')
def about():
	return '<p>67</p>'

@app.route('/db-check')
def db_check():
	conn = psycopg2.connect(
		host=os.environ.get('POSTGRES_HOST','db'),
		database=os.environ['POSTGRES_DB'],
		user=os.environ['POSTGRES_USER'],
		password=os.environ['POSTGRES_PASSWORD']
	)
	cur = conn.cursor()
	cur.execute('SELECT version();')
	version = cur.fetchone()
	cur.close()
	conn.close()
	return f'<p>BD connected, version: {version[0]}</p>'

@app.route('/counter')
def counter():
	count = r.incr('visits')
	return f'<p> This page was opened {count} time(s)</p>'

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
