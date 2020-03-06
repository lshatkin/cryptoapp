
import requests
import json
from html.parser import HTMLParser
import re
import pandas as pd 
import datetime 
from ast import literal_eval



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
    df.to_csv('./data/coinCalender.csv')

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
        print(response.json())
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
    df.to_csv('./data/coindar.csv')


# api key: 27eg1E3o0P3liG2hqumJB9RLlVXFIzcR3HLt3VWc
def coinmarketcalapi():

    url = "https://developers.coinmarketcal.com/v1/events"
    payload = ""
    headers = {
        'x-api-key': "27eg1E3o0P3liG2hqumJB9RLlVXFIzcR3HLt3VWc",
        'Accept-Encoding': "deflate, gzip",
        'Accept': "application/json"
    }
    
    data_array = []
    count = 0
    page = 1
    while page > 0:
        print(page)
        querystring = {"page":page, "max":75}
        response = requests.request("GET", url, data=payload, headers=headers, params=querystring)
        parsed = json.loads(response.content.decode('latin1'))
        page += 1
        if parsed['body'] is None:
            break
        for entry in parsed['body']:
            count += 1
            try:
                start_date = entry['date_event']
                start_date = start_date[0:start_date.find('T')]
                coin = entry['coins'][0]
                data_entry = {'coin_symbol': coin['symbol'],
                                'start' : start_date,
                                'title' : entry['title']['en'], 'coin_name' : coin['name'], 'source' :entry['source']}
                data_array.append(data_entry)                
            # Means its gotten all the events
            except:
                page = -1
                break
    df=pd.DataFrame(columns = ['coin_symbol', 'start', 'title', 'coin_name', 'source'], data = data_array)
    df.to_csv('./data/coinMarketCal.csv')



if __name__ == '__main__':
    print('Starting...')
    # coincalenderapi()
    # print('Finished Part 1...')
    # coindarapi()
    # print('Finished Part 2...')
    # coinmarketcalapi()
    # print('Finished Part 3...')





