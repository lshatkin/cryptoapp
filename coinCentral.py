import requests
import selenium
from bs4 import BeautifulSoup
from selenium import webdriver
import sys
import pandas as pd 
import unittest, time, re

# Get the number of pages
def get_num_pages(driver):
    page_numbers=[]
    page_numbers = driver.find_elements_by_class_name("page-numbers")
    max_page = 0
    for i in page_numbers:
        try:
            if (int(i.text) > max_page):
                max_page = int(i.text)
        except:
            pass
    return max_page

def add_to_link_array(data, all_links):
    soup = BeautifulSoup(data, 'html.parser')
    for link in soup.find_all('a'):
        url = link.get('href')
        if url is not None and "what" in url.lower() and "is" in url.lower():
            all_links.add(url)



def get_html_total(base_url):
    driver = webdriver.Chrome()
    driver.implicitly_wait(30)
    driver.get(base_url)
    max_page = get_num_pages(driver)
    page_number = 1
    all_links = set()
    while True:
        html_source = driver.page_source
        data = html_source.encode('utf-8')
        add_to_link_array(data, all_links)
        if page_number == max_page:
            break
        else:
            page_number += 1
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(2)
        clickme = driver.find_element_by_xpath('//a[contains(@class,"next page-numbers")]')
        clickme.click()
        time.sleep(2)
    driver.close()
    return all_links

        
if __name__ == "__main__":
    urls = ['https://coincentral.com/category/altcoins/', 'https://blockonomi.com/category/guides/']
    names = ['coinCentral', 'blockonomi']
    count = 0
    for base_url in urls:
        print(base_url)
        all_links = get_html_total(base_url)
        links_df = pd.DataFrame(data= all_links, columns = ['link'])
        links_df.to_csv('./data/%s.csv' % names[count])
        count += 1




