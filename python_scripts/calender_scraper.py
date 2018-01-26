
import requests
import json
from html.parser import HTMLParser
import re
import pandas as pd 
import datetime 



# Used for CoinCalender.com
class MyHTMLParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.events = []
        self.pop = 'pop'
        self.num_events = 0

    def handle_data(self, data):
        if ((data[0] == '{') and (self.num_events < 10)):
            # puts all words in quotes into an array
            data_array = re.findall('"([^"]*)"', data)
            title = (data_array[data_array.index('name') + 1])
            try: 
                coin_symbol = title[(title.index('(') + 2):title.index(')')]
                name = title[0:(title.index('('))]
            except: 
                coin_symbol = 'Unknown'
                name = 'Unknown'
            start = (data_array[data_array.index('startDate') + 1])
            start = start[0:start.index('T')]
            description = (data_array[data_array.index('description') + 1])
            data_entry = {'coin_symbol' : coin_symbol,  'coin_name' : name, 'title' : title, 'start' : start, 
                            'description' : description}
            self.events.append(data_entry)

def coincalenderapi():
    # Might need to get more events
    response = requests.get("http://www.coincalendar.info/wp-json/eventon/calendar?event_type=3,1266,1267,564&number_of_months=3&event_count=2000&show_et_ft_img=no'")
    response_json = response.json()

    parser = MyHTMLParser()
    parser.feed(response_json['html'])
    df = pd.DataFrame(columns = ['coin_symbol', 'coin_name', 'title','start','description'], data = parser.events)
    df.to_csv('~/Desktop/crypto/crypto_shiny/data/coinCalender.csv')

# Get events for specific year, month and day:
# https://coindar.org/api/v1/events?Year=2017&Month=10
# https://coindar.org/api/v1/events?year=2017&month=10&day=16
# Get last X events:
# https://coindar.org/api/v1/lastEvents?limit=300
# Get events from coin X:
# https://coindar.org/api/v1/coinEvents?name=btc
def coindarapi():

    data_array = []
    now = datetime.datetime.now()
    this_year = now.year
    this_month = now.month

    # Get all events for the next 10 months
    for count in range(10):
        response = requests.get('https://coindar.org/api/v1/events?Year=' + str(this_year) + '&Month=' + str(this_month))
        response_json = response.json()
        for entry in response_json:
            publication_date = entry['public_date']
            publication_date = publication_date[0:publication_date.find(' ')]
            data_entry = {'coin_symbol': entry['coin_symbol'], 'coin_name' : entry['coin_name'], 
                            'description' : entry['caption'], 'publication_date' : publication_date,
                             'start' : entry['start_date']}
            data_array.append(data_entry)
        if (this_month == 12):
            this_month = 1
            this_year += 1
        else:
            this_month += 1
    df=pd.DataFrame(columns = ['coin_symbol', 'coin_name', 'description','publication_date',
                                'start'], data = data_array)
    df.to_csv('~/Desktop/crypto/crypto_shiny/data/coindar.csv')

def coinmarketcalapi():

    data_array = []
    now = datetime.datetime.now()
    this_year = now.year
    this_month = now.month
    for count in range(10):
        if this_month < 10:
            month_string = '0' + str(this_month)
        else:
            month_string = str(this_month)
        response = requests.get('https://coinmarketcal.com/api/events?month=' + month_string + '&year=' + str(this_year) + '&max=100&page=1')
        response_json = response.json()
        for entry in response_json:
            publication_date = entry['created_date']
            publication_date = publication_date[0:publication_date.find('T')]
            start_date = entry['date_event']
            start_date = start_date[0:start_date.find('T')]
            data_entry = {'coin_symbol': entry['coin_symbol'], 'description' : entry['description'],
                            'publication_date' : publication_date, 'start' : start_date,
                            'validation_percentage' : entry['percentage'], 'title' : entry['title'],
                            'coin_name' : entry['coin_name']}
            data_array.append(data_entry)
        if (this_month == 12):
            this_month = 1
            this_year += 1
        else:
            this_month += 1
    df=pd.DataFrame(columns = ['coin_symbol', 'coin_name', 'description','publication_date',
                            'start', 'title', 'validation_percentage'], data = data_array)
    df.to_csv('~/Desktop/crypto/crypto_shiny/data/coinMarketCal.csv')



if __name__ == '__main__':
    print('Starting...')
    coincalenderapi()
    print('Finished Part 1...')
    # coindarapi()
    # print('Finished Part 2...')
    # coinmarketcalapi()

    print('Finished Part 3...')





