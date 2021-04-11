import os
from google.cloud.devtools import cloudbuild_v1
client = cloudbuild_v1.CloudBuildClient()
#os.environ["GOOGLE_APPLICATION_CREDENTIALS"]= "/c/Users/Sulagna/GCPCert/ServiceAccounts/credentials.json"
project_id = "ari-project-1982"
build = {
    "steps": [{
        "name": "gcr.io/cloud-builders/gcloud",
        "entrypoint":"bash",
        "args": [
        "-c",
        "gcloud compute ssh umyfashion@tf-self-hosted-runner --zone=europe-west1-b --command=\"sudo docker run -d --name github-runner-3 ghshr:v1\"\n"
      ]
    }]
}

def create_build(request):
     response = client.create_build(
     project_id="ari-project-1982",
     build=cloudbuild_v1.Build(build),
     )