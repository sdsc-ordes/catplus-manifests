import requests

datafile = "data/datafile.ttl"
shapesfile = "data/shapesfile.ttl"
endpoint = "/validate"

headers = {
  'accept': 'application/json',
  'Content-Type': 'application/x-www-form-urlencoded',
}

response = requests.post(
    'http://localhost:15400'+endpoint,
    data={'datafile': open(datafile).read(), 'shapesfile': open(shapesfile).read()},
    headers=headers
)

print(response.text)
print(response.json())