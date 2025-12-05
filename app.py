import os
from flask import Flask
import redis

app = Flask(__name__)

# Подключаемся к Redis.
# Обрати внимание: host='redis'. Это не IP, это имя сервиса в Docker!
# Docker сам превратит 'redis' в нужный IP адрес (Magic DNS).
r = redis.Redis(host=os.environ.get('REDIS_HOST', 'redis'), port=6379)

@app.route('/')
def hello():
    try:
        # Увеличиваем счетчик
        count = r.incr('hits')
        return f"Hello from CD Pipeline! Version 2! Count: {count}.\n"
    except redis.exceptions.ConnectionError as e:
        return f"Error connecting to Redis: {str(e)}\n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
    