links = read.csv('~/Desktop/crypto/crypto_shiny/data/captainAltCoin.csv', stringsAsFactors = FALSE)
price_info = read.csv('~/Desktop/crypto/crypto_shiny/data/price_information.csv')
strings = c('raiblocks', 'paypie', 'burst', 'stellar', 'lloyd')

for (name in strings){
    pop <- ''
    for (row in 1:nrow(links)){
        link <- links[row, 'link']
        if (grepl(name, link, ignore.case = TRUE)){
            pop <- name
            break
        }
        pop <- 'nothing'
    }
    print(pop)

}
    

