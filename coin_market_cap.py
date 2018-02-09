import requests
import json
import pandas as pd 


def format_entry(entry):
    symbol = entry['symbol']
    name = entry['name']
    if not entry['price_btc']:
        price_btc = 'Unknown'
    else:
        price_btc = entry['price_btc'] + ' BTC'
    if not entry['price_usd']:
        price_usd = 'Unknown'
    else:
        price_usd = '$' + entry['price_usd'][0:4]
    if not (entry['percent_change_1h']):
        percent_change_1h = 'Unknown'
    else:
        percent_change_1h = entry['percent_change_1h'] + '%'
    if not entry['percent_change_24h']:
        percent_change_24h = 'Unknown'
    else:
        percent_change_24h = entry['percent_change_24h'] + '%'
    if not entry['24h_volume_usd']:
        volume_usd_24h = 'Unknown'
    else:
        volume_usd_24h = "{:,}".format(float(entry['24h_volume_usd']))
    if not entry['market_cap_usd']:
        market_cap_usd = 'Unknown'
    else:
        market_cap_usd = '$' + "{:,}".format(float(entry['market_cap_usd']))
    if not entry['available_supply']:
        available_supply = 'Unknown'
    else:
        available_supply = "{:,}".format(float(entry['available_supply']))
    if not entry['max_supply']:
        max_supply = 'Unknown'
    else:
        max_supply = "{:,}".format(float(entry['max_supply']))
    data_entry = [symbol, name, price_btc, price_usd, percent_change_1h,
                    percent_change_24h, volume_usd_24h, market_cap_usd,
                    available_supply, max_supply]
    return data_entry


def coinMarketCap():
    df = pd.DataFrame(columns = ['symbol', 'name', 'price_btc',
                                    'price_usd', 'percent_change_1h',
                                    'percent_change_24h', 'volume_usd_24h',
                                    'market_cap_usd', 'available_supply',
                                    'max_supply'])
                                   

    response = requests.get('https://api.coinmarketcap.com/v1/ticker/?limit=0')
    response_json = response.json()

    count = 0
    for entry in response_json:
        print(count, "/", len(response_json))
        count += 1
        data_entry = format_entry(entry)
        df.loc[len(df.index)] = data_entry
    return df

if __name__ == '__main__':
    df = coinMarketCap()
    df.to_csv('~/Desktop/crypto/research_infrastructure/price_information.csv')