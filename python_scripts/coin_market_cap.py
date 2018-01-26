import requests
import json
import pandas as pd 



def coinMarketCap():
    df = pd.DataFrame(columns = ['symbol', 'name', 'price_btc',
                                    'price_usd', 'percent_change_1h',
                                    'percent_change_7d', 'volume_usd_24h',
                                    'market_cap_usd', 'max_supply', 
                                    'available_supply', 'total_supply'])
                                   

    response = requests.get('https://api.coinmarketcap.com/v1/ticker/?limit=0')
    response_json = response.json()

    count = 0
    for entry in response_json:
        print(count, "/", len(response_json))
        count += 1
        data_entry = [entry['symbol'], entry['name'],
                        entry['price_btc'], entry['price_usd'],
                        entry['percent_change_1h'], entry['percent_change_7d'],
                        entry['24h_volume_usd'], entry['market_cap_usd'],
                        entry['max_supply'], entry['available_supply'],
                        entry['total_supply']]
        df.loc[len(df.index)] = data_entry
    return df

if __name__ == '__main__':
    df = coinMarketCap()
    df.to_csv('~/Desktop/crypto/crypto_shiny/data/price_information.csv')