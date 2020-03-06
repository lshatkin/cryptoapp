import pandas as pd 
from requests import Request, Session
from requests.exceptions import ConnectionError, Timeout, TooManyRedirects
import json


def format_entry(entry):
    symbol = entry['symbol']
    name = entry['name']
    pricing = entry['quote']['USD']
    if not pricing['price']:
        price_usd = 'Unknown'
    else:
        price_usd = '$' + str(pricing['price'])[0:4]
    if not (pricing['percent_change_1h']):
        percent_change_1h = 'Unknown'
    else:
        percent_change_1h = str(pricing['percent_change_1h']) + '%'
    if not pricing['percent_change_24h']:
        percent_change_24h = 'Unknown'
    else:
        percent_change_24h = str(pricing['percent_change_24h']) + '%'
    if not pricing['volume_24h']:
        volume_usd_24h = 'Unknown'
    else:
        volume_usd_24h = "{:,}".format(float(pricing['volume_24h']))
    if not pricing['market_cap']:
        market_cap_usd = 'Unknown'
    else:
        market_cap_usd = '$' + "{:,}".format(float(pricing['market_cap']))
    if not entry['circulating_supply']:
        available_supply = 'Unknown'
    else:
        available_supply = "{:,}".format(float(entry['circulating_supply']))
    if not entry['max_supply']:
        max_supply = 'Unknown'
    else:
        max_supply = "{:,}".format(float(entry['max_supply']))
    data_entry = [symbol, name, price_usd, percent_change_1h,
                    percent_change_24h, volume_usd_24h, market_cap_usd,
                    available_supply, max_supply]
    return data_entry

# d47ce585-1581-4973-9543-0d26178ee344
def coinMarketCap():

    url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'
    parameters = {
      'start':'1',
      'limit':'5000',
      'convert':'USD'
    }
    headers = {
      'Accepts': 'application/json',
      'X-CMC_PRO_API_KEY': 'd47ce585-1581-4973-9543-0d26178ee344',
    }

    session = Session()
    session.headers.update(headers)

    try:
      response = session.get(url, params=parameters)
      data = json.loads(response.text)['data']
    except (ConnectionError, Timeout, TooManyRedirects) as e:
      print(e)

    df = pd.DataFrame(columns = ['symbol', 'name',
                                    'price_usd', 'percent_change_1h',
                                    'percent_change_24h', 'volume_usd_24h',
                                    'market_cap_usd', 'available_supply',
                                    'max_supply'])
                                   
    count = 0
    for entry in data:
        print(count, "/", len(data))
        count += 1
        data_entry = format_entry(entry)
        df.loc[len(df.index)] = data_entry
    return df

if __name__ == '__main__':
    df = coinMarketCap()
    df.to_csv('./data/price_information.csv')