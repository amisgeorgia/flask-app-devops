FROM python:3.12-slim

# Sécurité : ne pas tourner en root
RUN useradd --create-home flask

WORKDIR /home/flask

# Copier et installer les dépendances
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code
COPY . .

RUN chmod a+x app.py test.py && \
    chown -R flask:flask ./

ENV FLASK_APP=app.py
EXPOSE 5000

USER flask
CMD ["python", "app.py"]