# =========== STAGE 1: Builder ===========
# Берем образ python (версия slim - облегченная)
FROM python:3.9-slim as builder

WORKDIR /app

# Устанавливаем зависимости системы (если нужны для сборки библиотек)
# Для flask/redis это не обязательно, но хорошая практика показать
RUN apt-get update && apt-get install -y --no-install-recommends gcc

# Создаем виртуальное окружение и ставим либы
RUN python -m venv /opt/venv
# Активируем venv для следующих команд
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# =========== STAGE 2: Runner ===========
# Берем СВЕЖИЙ, чистый образ. Весь мусор от apt-get и gcc остался в stage 1
FROM python:3.9-slim

WORKDIR /app

# Создаем пользователя (не root!), чтобы хакер не получил доступ к хосту
RUN useradd -m appuser

# Копируем готовое виртуальное окружение из Stage 1
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Копируем код приложения
COPY app.py .

# Меняем владельца файлов
RUN chown -R appuser:appuser /app

# Переключаемся на пользователя
USER appuser

# Говорим Докеру, что приложение слушает порт 5000
EXPOSE 5000

# Команда запуска
CMD ["python", "app.py"]