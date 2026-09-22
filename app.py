from flask import Flask
import psycopg2

app = Flask(__name__)

@app.route('/')
def home():
	return '<h1>Привет, Данил! Это твой первый веб-сервер в Докер!)</h1>'

@app.route('/about')
def about():
	return '<p>6767676767</p>'

@app.route('/db-check')
def db_check():
	conn = psycopg2.connect(
		host='db',
		database='mydatabase',
		user='myuser',
		password='mypassword'
	)
	cur = conn.cursor()
	cur.execute('SELECT version();')
	version = cur.fetchone()
	cur.close()
	conn.close()
	return f'<p>Подключение к базе успешно! Версия: {version[0]}</p>'

app.run(host='0.0.0.0', port=5000)
