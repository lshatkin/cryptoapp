import requests
import selenium
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import NoAlertPresentException
import sys
import pandas as pd 

import unittest, time, re

class Sel(unittest.TestCase):

    def __init__(self):
        self.driver = webdriver.Chrome('/Users/lloyd16/Desktop/crypto/research_infrastructure/chromedriver.exe')
        self.driver.implicitly_wait(30)
        self.base_url = 'https://captainaltcoin.com/altcoins/'
        self.verificationErrors = []
        self.accept_next_alert = True

    def get_html_total(self):
        driver = self.driver
        driver.get(self.base_url)
        last_height = driver.execute_script("return document.body.scrollHeight")
        while True:
            self.driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
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
    sel_instance = Sel()
    data = sel_instance.get_html_total()
    all_links = get_links(data)
    links_df = pd.DataFrame(data= all_links, columns = ['link'])
    links_df.to_csv('~/Desktop/crypto/research_infrastructure/captainAltCoin.csv')









