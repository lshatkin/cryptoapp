import json
import requests

response = requests.get('https://glacial-ocean-28763.herokuapp.com/', params = {
    "coin" : "BTC/USD",
    "limit" : 200,
    "resolution" : 900,
    "exchange" : "GDAX"
    })

# ?coin=BTC/USD&limit=200&resolution=900&exchange=GDAX')
# print(response.json())

for event in response.json()['results']:
    print(event)

