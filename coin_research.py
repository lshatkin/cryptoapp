# Import the necessary methods from tweepy library
import requests
import json
from html.parser import HTMLParser
import pandas as pd
import re

def cleanhtml(raw_html):
  cleanr = re.compile('<.*?>')
  cleantext = re.sub(cleanr, '', raw_html)
  return cleantext


def get_possible_ids():
    response = requests.get('https://min-api.cryptocompare.com/data/all/coinlist')
    response_json = response.json()

    # This gets basic information aobut the coin, as well as simply all the coins
    # that cryptocompare has within their database. This is the CoinList api
    # as referenced on the website
    coins = {}
    for coin in response_json['Data']:
        coin_id = response_json['Data'][coin]['Id']
        coins[coin] = coin_id
    return coins

def create_basic_info_df():
    info_df = pd.DataFrame(columns = ['coin_name','symbol', 'description',
                                        'total_coin_supply', 'algorithm', 
                                        'proof', 'start_date', 'total_coins_mined',
                                        'exchanges'])

    return info_df

def extract_exchange(sub_array):
    exchange_array = []
    for exchange in sub_array:
        seperated = exchange.replace('~', ' ')
        split = seperated.split(' ')
        if split[1] not in exchange_array:
            exchange_array.append(split[1])
    return exchange_array


def get_basic_information(coin_list, coin_df):
    coin_dictioanry = {'coin_name' : {'other_facts'}}
    count = 0
    for coin_id in coin_list.values():
        print(count, '/', len(coin_list.values()))
        count += 1
        response = requests.get('https://www.cryptocompare.com/api/data/coinsnapshotfullbyid/?id=' + coin_id)
        response_json = response.json()
        subs = response_json['Data']['Subs']
        exchange_array = ', '.join(extract_exchange(subs))
        general = response_json['Data']['General']     
        coin_df.loc[len(coin_df.index)] = [general['Name'], general['Symbol'], cleanhtml(general['Description']), 
                                        general['TotalCoinSupply'], general['Algorithm'],
                                        general['ProofType'], general['StartDate'], general['TotalCoinsMined'],
                                        exchange_array]
    return coin_df


def test():
    response = requests.get('https://www.cryptocompare.com/api/data/miningequipment/')
    response_json = response.json()
    print(response_json)
          
if __name__ == '__main__':
    coin_list = get_possible_ids()
    coin_df = create_basic_info_df()
    coin_df = get_basic_information(coin_list, coin_df)
    coin_df.to_csv('~/Desktop/crypto/research_infrastructure/initial_coin_research.csv')








