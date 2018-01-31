import pandas as pd

links = pd.read_csv('~/Desktop/crypto/crypto_shiny/data/captainAltCoin.csv')
price_info = pd.read_csv('~/Desktop/crypto/crypto_shiny/data/price_information.csv')
strings = ['raiblocks', 'paypie', 'burst', 'stellar']

# for name in strings:
#     for link_index in links.index:
#         link=links.loc[link_index, 'link']
#         if (name in link):
#             print('------')
#             print(name, link)
#             continue

for i in price_info.index:
    print(i)
    for link_index in links.index:
        link = links.loc[link_index,'link']
        name = price_info.loc[i, 'name'].lower()
        print(name)
        symbol = price_info.loc[i, 'symbol']

        if ((name in link) or (symbol in link)):
            print('-------------------------')
            print (price_info.loc[i, 'name'], price_info.loc[i, 'symbol'])
            print(link)
            continue
