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
                                        'exchanges', 'official_website'])

    return info_df

def create_social_df():
    social_df = pd.DataFrame(columns = ['coin_name', 'symbol', 'twitter',
                                            'reddit'])
    return social_df

def extract_exchange(sub_array):
    exchange_array = []
    for exchange in sub_array:
        seperated = exchange.replace('~', ' ')
        split = seperated.split(' ')
        if split[1] not in exchange_array:
            exchange_array.append(split[1])
    return exchange_array


def get_basic_information(coin_list, coin_df):
    count = 0
    for coin_id in coin_list.values():
        print(count, '/', len(coin_list.values()))
        count += 1
        response = requests.get('https://www.cryptocompare.com/api/data/coinsnapshotfullbyid/?id=' + coin_id)
        response_json = response.json()
        subs = response_json['Data']['Subs']
        exchange_array = ', '.join(extract_exchange(subs))
        general = response_json['Data']['General']   
        official_website = 'Unknown'
        if (len(re.findall(r"'(.*?)'", general['Website'])) > 0):
            official_website = (re.findall(r"'(.*?)'", general['Website']))[0]
        coin_df.loc[len(coin_df.index)] = [general['Name'], general['Symbol'], cleanhtml(general['Description']), 
                                        general['TotalCoinSupply'], general['Algorithm'],
                                        general['ProofType'], general['StartDate'], general['TotalCoinsMined'],
                                        exchange_array, official_website]
    return coin_df


def get_social_information(coin_list, social_df):
    count = 0
    for coin_id in coin_list.values():
        print(count, '/', len(coin_list.values()))
        count += 1
        response = requests.get('https://www.cryptocompare.com/api/data/socialstats/?id=' + coin_id)
        response_json = response.json()
        data = response_json['Data']
        symbol = data['General']['Name']
        name = data['General']['CoinName']
        twitter_link = 'Unknown'
        if (len(data['Twitter']) > 1):
            twitter_link = data['Twitter']['link']
        reddit_link = 'Unknown'
        if (len(data['Reddit']) > 1):
            reddit_link = data['Reddit']['link']
        social_df.loc[len(social_df.index)] = [name, symbol, twitter_link, reddit_link]
    return social_df

          
if __name__ == '__main__':
    coin_list = get_possible_ids()
    # Get basic information about coin
    coin_df = create_basic_info_df()
    coin_df = get_basic_information(coin_list, coin_df)
    coin_df.to_csv('~/Desktop/crypto/research_infrastructure/initial_coin_research.csv')
    # Get twitter and reddit links for coins
    # social_df = create_social_df()
    # get_social_information(coin_list, social_df)
    # social_df.to_csv('~/Desktop/crypto/research_infrastructure/social_media_links.csv')







