# Verwende ein Python 3.11-Image als Basis
FROM python:3.11-slim

# Erstelle einen Ordner /app
RUN mkdir /app

# Setze das Arbeitsverzeichnis im Container
WORKDIR /app

COPY templates /app/templates

COPY static /app/static

# Kopiere die restlichen Dateien in das Arbeitsverzeichnis
COPY app.py requirements.txt /app/

RUN pip install -r requirements.txt

# Setze die Umgebungsvariable für den Flask-Server
ENV FLASK_APP=app.py

# Setze den Port, auf dem der Flask-Server laufen soll
EXPOSE 5000

# Starte den Flask-Server beim Starten des Containers
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]

