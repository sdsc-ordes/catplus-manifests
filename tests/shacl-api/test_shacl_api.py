import requests
import base64

datafile = "data/datafile_catplus.ttl"
shapesfile = "data/shapesfile_catplus.ttl"
endpoint = "/validate"

datafile_string = open(datafile).read()
shapesfile_string = open(shapesfile).read()

datafile_b64 = base64.b64encode(datafile_string.encode())
shapesfile_b64 = base64.b64encode(shapesfile_string.encode())

headers = {
  'accept': 'application/json',
  'Content-Type': 'application/x-www-form-urlencoded',
}

response = requests.post(
    'http://localhost:15400'+endpoint,
    data={'datafile': datafile_b64, 'shapesfile': shapesfile_b64},
    headers=headers
)

print(response.json())