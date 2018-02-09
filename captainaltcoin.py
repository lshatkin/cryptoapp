import requests
import selenium
from bs4 import BeautifulSoup
from selenium import webdriver
import sys
import pandas as pd 
import unittest, time, re


def get_html_total():
    driver = webdriver.Chrome('/Users/lloyd16/Desktop/crypto/research_infrastructure/chromedriver.exe')
    driver.implicitly_wait(30)
    base_url = 'https://captainaltcoin.com/altcoins/'
    driver.get(base_url)
    last_height = driver.execute_script("return document.body.scrollHeight")
    while True:
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(4)
        new_height = driver.execute_script("return document.body.scrollHeight")
        if new_height == last_height:
            break
        last_height = new_height
    html_source = driver.page_source
    data = html_source.encode('utf-8')
    driver.close()
    return data

def get_links(data):
    soup = BeautifulSoup(data, 'html.parser')
    all_links = []
    for link in soup.find_all('a'):
        if ((link not in all_links) and (link.get('href').startswith('https://captainaltcoin.com'))):
            all_links.append(link.get('href'))
    return all_links
        
if __name__ == "__main__":
    data = get_html_total()
    all_links = get_links(data)
    links_df = pd.DataFrame(data= all_links, columns = ['link'])
    links_df.to_csv('~/Desktop/crypto/research_infrastructure/captainAltCoin.csv')









