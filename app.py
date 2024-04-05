import os
import requests
from flask import Flask, render_template, request, jsonify
import base64
import hashlib
from google.cloud import firestore

# Lese AUTH_TOKEN und PROJECT_ID aus Umgebungsvariablen
AUTH_TOKEN = os.getenv('AUTH_TOKEN')
PROJECT_ID = os.getenv('PROJECT_ID')

app = Flask(__name__, static_folder='static')

db = firestore.Client()

def calculate_image_hash(image):
    sha256_hash = hashlib.sha256()
    sha256_hash.update(image)
    return sha256_hash.hexdigest()

def check_hash_in_database(hash_value):
    existing_hash = db.collection('images').document(hash_value)
    return existing_hash.get().exists

def save_to_database(hash_value, api_response):
    db.collection('images').document(hash_value).set({
        'api_response': api_response
    })

# TODO: db connection
def get_db_connection():
    pass

@app.route('/')
def index():
    return render_template('index.html')


@app.route('/upload', methods=['POST'])
def upload():
    if 'image-input' not in request.files:
      return jsonify({'error': 'Kein Bild hochgeladen'}), 400
    
    image =request.files['image-input']
    image_bytes = image.read()

    image_hash = calculate_image_hash(image_bytes)

    if check_hash_in_database(image_hash):
        description = db.collection('images').document(image_hash).get().to_dict()['api_response']
        return render_template('index.html', output=description)
    
    else:
      encoded_image = base64.b64encode(image_bytes).decode('utf-8')
      
      # API URL und Token anpassen
      api_url = f"https://us-central1-aiplatform.googleapis.com/v1/projects/{PROJECT_ID}/locations/us-central1/publishers/google/models/gemini-1.0-pro-vision:streamGenerateContent"
      
      headers = {
          "Authorization": f"Bearer {AUTH_TOKEN}",
          "Content-Type": "application/json; charset=utf-8",
      }
      data = {
        "contents": {
          "role": "USER",
          "parts": [
            {
              "inlineData": {
                "mimeType": image.mimetype,
                "data": encoded_image
              }
            },
            {
              "text": "Describe this picture."
            }
          ]
        },
        "safety_settings": {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_LOW_AND_ABOVE"
        },
        "generation_config": {
          "temperature": 0.4,
          "topP": 1.0,
          "topK": 32,
          "maxOutputTokens": 2048
        }
      } 
  
      response = requests.post(api_url, json=data, headers=headers)
      
      if response.status_code == 200:
          api_response = response.json()  # Ersetze dies mit dem tatsächlichen Aufruf der API und der Antwortverarbeitung
          try:
              # Gehe davon aus, dass die API mehrere Kandidaten zurückgeben kann und wir die Beschreibung aus dem ersten nehmen
              description = api_response[0]['candidates'][0]['content']['parts'][0]['text']
              save_to_database(image_hash, description)
              return render_template('index.html', output=description)  # Direkte Rückgabe der Beschreibung als String
          except (IndexError, KeyError) as e:
              return 'Fehler beim Extrahieren der Beschreibung aus der API-Antwort'  # Fehler-String Rückgabe
      else:
          print(response.content)
          return 'Fehler bei der Verarbeitung der Anfrage'  # Fehler-String Rückgabe


if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True)

