import requests
from bs4 import BeautifulSoup
import json
import pandas as pd


def create_array():
    crypto_list_page = requests.get('https://www.mycryptopedia.com/cryptocurrencies/')
    crypto_soup = BeautifulSoup(crypto_list_page.content, 'html.parser')
    all_links = []
    for link in crypto_soup.find_all('a'):
        if link not in all_links:
            all_links.append(link.get('href'))
    return all_links


if __name__ == '__main__':
    all_links = create_array()
    link_df = pd.DataFrame(data = all_links, columns = ['link'])
    link_df.to_csv('~/Desktop/crypto/research_infrastructure/myCryptopedia.csv')



