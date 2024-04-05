# TODO(developer): Vertex AI SDK - uncomment below & run
# pip3 install --upgrade --user google-cloud-aiplatform
# gcloud auth application-default login

import vertexai
from vertexai.generative_models import GenerativeModel, Part

project_id = 'testprojekt-332515'
location = 'us-central1'
vertexai.init(project=project_id, location=location)

multimodal_model = GenerativeModel("gemini-pro")
    # Query the model
response = multimodal_model.generate_content('Say hi')

print(response.text)

