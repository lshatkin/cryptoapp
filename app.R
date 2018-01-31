library(shiny)
library(shinythemes)
library(shinyjs)
library(dplyr)
library(xtable)
library(knitr)
library(shinythemes)
library(rsconnect)


# https://captainaltcoin.com/altcoins/
# https://shiny.rstudio.com/articles/tag-glossary.html

##############################################
# These first three functions are used to run the python research scripts,
# and overwrite the current CSV files that are saved. The 'Price Info' script
# should probably be run often (we want current prices), the 'Calender Scraper'
# can be run once a day or so, and the coin description probably does not need
# to be run very often. Will stay the same.
##############################################

run_price_info <- function(){
    command = 'python'
    script_to_run = 'coin_market_cap.py'
    system2(command, args = script_to_run)
}

run_coin_description <- function(){
    command = 'python'
    script_to_run = 'coin_research.py'
    system2(command, args = script_to_run)
}

run_calender_scraper <- function(){
    command = 'python'
    script_to_run = 'calender_scraper.py'
    system2(command, args = script_to_run)
}

run_website_link_getters <- function(){
    command = 'python'
    script_to_run = 'coinCentral.py'
    system2(command, args = script_to_run)
    script_to_run = 'captainaltcoin.py'
    system2(command, args = script_to_run)
    script_to_run = 'myCryptopedia.py'
    system2(command, args = script_to_run)
} 



# run_calender_scraper()
# run_coin_description()
# run_price_info()
coin_description_df <- read.csv('initial_coin_research.csv', stringsAsFactors=F)
price_information <- read.csv('price_information.csv', stringsAsFactors = F)
coinCalender <- read.csv('coinCalender.csv', stringsAsFactors = F)
coinMarketCal <- read.csv('coinMarketCal.csv', stringsAsFactors = F)
coindar <- read.csv('coindar.csv', stringsAsFactors = F)
links_captainAlt <- read.csv('captainAltCoin.csv', stringsAsFactors = F)
links_myCrypto <- read.csv('myCryptopedia.csv', stringsAsFactors = F)
links_coinCentral <- read.csv('coinCentral.csv', stringsAsFactors = F)

ui <- fluidPage(
    theme = shinytheme("spacelab"),
    titlePanel("Viceroy Research Infrastructure"),
    sidebarLayout(
        sidebarPanel(
            selectInput("coin_symbol", "Coin Symbol", choices = c('All', price_information$symbol))
        ),
        mainPanel(
            tabsetPanel(
                tabPanel('General Description of Coin', 
                    htmlOutput('general'),
                    htmlOutput('price_info')),
                tabPanel('Initial Research Guide', 
                    uiOutput('links')),
                tabPanel('Social Media and Community',
                    htmlOutput('tweets')),
                tabPanel('Upcoming Events', 
                    htmlOutput('coinMarketCal'),
                    htmlOutput('coindar'),                    
                    htmlOutput('coinCalender'))
            )
        )
    )
)


server <- function(input, output) {
    
    output$links <- renderUI({
        if (input$coin_symbol == 'All'){
            'Coming soon...'
        }
        else{
            coin_name <- price_information[price_information$symbol == input$coin_symbol, 'name']

            for (row in 1:nrow(links_captainAlt)){
                link <- links_captainAlt[row, 'link']
                if (grepl(coin_name, link, ignore.case = TRUE) | grepl(input$coin_symbol, link, ignore.case = TRUE)){
                    if (grepl('cryptocurrency', link) | grepl('what-is', link)){
                        captainaltcoin_final <- tags$a(href = link, 'Captain Altcoin Description')
                        break
                    }
                    else{
                        captainaltcoin_final <- tags$a(href = link, 'Captain Altcoin Description')
                    }
                }
                captainaltcoin_final <- 'No Available Article on Captain Altcoin'
            }

            for (row in 1:nrow(links_myCrypto)){
                link <- links_myCrypto[row, 'link']
                if (grepl(coin_name, link, ignore.case = TRUE) | grepl(input$coin_symbol, link, ignore.case = TRUE)){
                    mycryptopedia_final <- tags$a(href = link, 'MyCryptopedia Description')
                    break
                }
                mycryptopedia_final <- 'No Available Article on MyCryptopedia'
            }

            for (row in 1:nrow(links_coinCentral)){
                link <- links_coinCentral[row, 'link']
                if (grepl(coin_name, link, ignore.case = TRUE) | grepl(input$coin_symbol, link, ignore.case = TRUE)){
                    if (grepl('guide', link) | grepl('what-is', link)){
                        coinCentral_final <- tags$a(href = link, 'Coin Central Description')
                        break
                    }
                    else{
                        coinCentral_final <- tags$a(href = link, 'Captain Altcoin Description')
                    }
                }
                coinCentral_final <- 'No Available Article on MyCryptopedia'
            }


            cryptopanic <- paste('https://cryptopanic.com/news/', coin_name, '/', sep = '')
            cryptopanic_final <- tags$a(href = cryptopanic, "CryptoPanic Link")

            crypto_news <- paste('https://www.ccn.com/?s=', coin_name, '', sep = '')
            crypto_news_final <- tags$a(href = crypto_news, "Crypto News Related to Coin")

            youtube <- paste('https://www.youtube.com/results?search_query=what+is+', coin_name, '+coin', sep = '')
            youtube_final <- tags$a(href = youtube, 'YouTube Explanations')

            tags$ul(
                tags$li(captainaltcoin_final),
                tags$li(mycryptopedia_final),
                tags$li(coinCentral_final),
                # tags$li(cryptopanic_final),
                # tags$li(crypto_news_final),
                tags$li(youtube_final)
            )
        }
    })

    output$price_info <- renderUI({
        if (input$coin_symbol == 'All'){
            'Coming soon...'
        }
        else{
            info = (price_information[price_information$symbol == input$coin_symbol, ])
            str <- paste("Price BTC: ", info$price_btc)
            str1 <- paste("Price USD: ", info$price_usd)
            str2 <- paste("Percent Change 1h: ", info$percent_change_1h)
            str3 <- paste("Percent Change 24h: ", info$percent_change_24h)
            str4 <- paste("24h Volume (USD): ", info$volume_usd_24h)
            str5 <- paste("Market Cap: ", info$market_cap_usd)

            tags$div(
                str, 
                tags$br(), 
                str2, 
                tags$br(), 
                str3,
                tags$br(), 
                str4, 
                tags$br(), 
                str5
            )

        }
    })

    output$tweets <- renderUI({'Coming soon...'})

    output$general <- renderUI({

        if (input$coin_symbol == 'All'){
            'Coming soon...'
        }
        else{
            coin_info = (coin_description_df[coin_description_df$symbol == input$coin_symbol, ])
            # Sometimes the symbols from the two APIs don't match up, so try and find the coin
            # another way. For example, coinMarketCap has IOTA symbol = MIOTA, whereas 
            # cryptocompare has the symbol = IOT
            if (nrow(coin_info) == 0){
                coin_name = (price_information[price_information$symbol == input$coin_symbol, 'name'])
                coin_info = (coin_description_df[coin_description_df$coin_name == coin_name, ])
            }

            # If there was no 'proof', just say no available information
            proof <-  (if (nchar(coin_info$proof) == 0) 'No Available Information' else coin_info$proof)
            exchanges <- (if (nchar(coin_info$exchanges) == 0) 'No Available Information' else coin_info$exchanges)
            str <- paste("Coin Name: ", coin_info$coin_name)
            str2 <- paste("Coin Symbol: ", coin_info$symbol)
            str3 <- paste('Description: ', coin_info$description)
            str4 <- paste('Proof: ', proof)
            str5 <- paste('Exchanges to Trade on: ', exchanges)
            

            tags$div(
                str, 
                tags$br(), 
                str2, 
                tags$br(), 
                str3,
                tags$br(), 
                str4, 
                tags$br(), 
                str5
            )
        }

    })

    output$coinCalender <- renderUI({
        if (input$coin_symbol == 'All'){
            'Coming soon...'
        }
        else{
            events_1 = coinCalender[coinCalender$coin_symbol == input$coin_symbol, ]
            if (nrow(events_1) == 0){
                coin_name = (price_information[price_information$symbol == input$coin_symbol, 'name'])
                events_1 = (coinCalender[coinCalender$coin_name == coin_name, ])
            }
            if (nrow(events_1) == 0){
                'No information was gathered from coinCalender.info for this coin.'
            }
            else{
                str0 <- 'Information from coinCalender.info:'
                cutoff <- '------------------------------------------'
                all <- ''
                for (row in 1:nrow(events_1)){
                    str <- paste("Coin Name: ", events_1[row, 'coin_name'])
                    str2 <- paste("Coin Symbol: ", events_1[row, 'coin_symbol'])
                    str3 <- paste('Event Title: ', events_1[row, 'title'])
                    str4 <- paste('Start Date: ', events_1[row, 'start'])
                    str5 <- paste('Description: ', events_1[row,'description'])
                    all <- HTML(paste(all, str, str2, str3, str4, str5, cutoff, sep = '<br/>'))
                }
                tags$div(
                    tags$h1(str0),
                    tags$hr(), 
                    tags$br(),
                    all
                )
                
            }
        }


    })

    output$coindar <- renderUI({
        if (input$coin_symbol == 'All'){
            'Coming soon...'
        }
        else{
            events = coindar[coindar$coin_symbol == input$coin_symbol, ]
            if (nrow(events) == 0){
                coin_name = (price_information[price_information$symbol == input$coin_symbol, 'name'])
                events = (coindar[coindar$coin_name == coin_name, ])
            }
            if (nrow(events) == 0){
                'No information was gathered from coindar.org for this coin.'
            }
            else{
                str0 <- 'Information from coindar.org:'
                cutoff <- '------------------------------------------'
                all <- ''
                for (row in 1:nrow(events)){
                    str <- paste("Coin Name: ", events[row,'coin_name'])
                    str2 <- paste("Coin Symbol: ", events[row, 'coin_symbol'])
                    str3 <- paste('Publication Date: ', events[row, 'publication_date'])
                    str4 <- paste('Start Date: ', events[row,'start'])
                    str5 <- paste('Description: ', events[row,'description'])
                    all <- HTML(paste(all, str, str2, str3, str4, str5, cutoff, sep = '<br/>'))
                }
                tags$div(
                    tags$h1(str0),
                    cutoff, 
                    tags$br(),
                    all
                )
            }
        }

    })

    output$coinMarketCal <- renderUI({
        if (input$coin_symbol == 'All'){
            'Coming soon...'
        }
        else{
            events_2 = coinMarketCal[coinMarketCal$coin_symbol == input$coin_symbol, ]
            if (nrow(events_2) == 0){
                coin_name = (price_information[price_information$symbol == input$coin_symbol, 'name'])
                events_2 = (coinMarketCal[coinMarketCal$coin_name == coin_name, ])
            }
            if (nrow(events_2) == 0){
                'No information was gathered from coinMarketCal.com for this coin.'
            }
            else{
                str0 <- 'Information from coinMarketCal.com:'
                cutoff <- '------------------------------------------'
                all <- ''
                for (row in 1:nrow(events_2)){
                    str <- paste("Coin Name: ", events_2[row, 'coin_name'])
                    str2 <- paste("Coin Symbol: ", events_2[row, 'coin_symbol'])
                    str3 <- paste('Event Title: ', events_2[row,'title'])
                    str4 <- paste('Publication Date: ', events_2[row, 'publication_date'])
                    str5 <- paste('Start Date: ', events_2[row,'start'])
                    str6 <- paste('Description: ', events_2[row, 'description'])
                    str7 <- paste('Validation Percentage: ', str(events_2[row,'validation_percentage']))
                    all <- HTML(paste(all, str, str2, str3, str4, str5, str6, str7, cutoff, sep = '<br/>'))
                }
                tags$div(
                    tags$h1(str0), 
                    cutoff,
                    tags$br(),
                    all
                )
            }
        }

    })

}

shinyApp(ui = ui, server = server)
