library(shiny)
library(shinythemes)
library(shinyjs)
library(dplyr)
library(xtable)
library(knitr)
library(shinythemes)

##############################################
# These first three functions are used to run the python research scripts,
# and overwrite the current CSV files that are saved. The 'Price Info' script
# should probably be run often (we want current prices), the 'Calender Scraper'
# can be run once a day or so, and the coin description probably does not need
# to be run very often. Will stay the same.
##############################################

run_price_info <- function(){
    command = 'python'
    script_to_run = '~/Desktop/crypto/crypto_shiny/python_scripts/coin_market_cap.py'
    system2(command, args = script_to_run)
}

run_coin_description <- function(){
    command = 'python'
    script_to_run = '~/Desktop/crypto/crypto_shiny/python_scripts/coin_research.py'
    system2(command, args = script_to_run)
}

run_calender_scraper <- function(){
    command = 'python'
    script_to_run = '~/Desktop/crypto/crypto_shiny/python_scripts/calender_scraper.py'
    system2(command, args = script_to_run)
}



# run_calender_scraper()
# run_coin_description()
# run_price_info()
coin_description_df <- read.csv('~/Desktop/crypto/crypto_shiny/data/initial_coin_research.csv', stringsAsFactors=F)
price_information <- read.csv('~/Desktop/crypto/crypto_shiny/data/price_information.csv', stringsAsFactors = F)
coinCalender <- read.csv('~/Desktop/crypto/crypto_shiny/data/coinCalender.csv', stringsAsFactors = F)
coinMarketCal <- read.csv('~/Desktop/crypto/crypto_shiny/data/coinMarketCal.csv', stringsAsFactors = F)
coindar <- read.csv('~/Desktop/crypto/crypto_shiny/data/coindar.csv', stringsAsFactors = F)


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
                tabPanel('Recent Events and Tweets', textOutput('test')),
                tabPanel('Upcoming Events', 
                    htmlOutput('coinMarketCal'),
                    htmlOutput('coindar'),                    
                    htmlOutput('coinCalender'))
            )
        )
    )
)


server <- function(input, output) {
    
    output$test <- renderText({
        input$coin_symbol
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

            HTML(paste(str, str1, str2, str3,
                    str4, str5, sep = '<br/>'))
        }
    })

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

            # If there was no 'proof' data, just say no available information
            proof <-  (if (nchar(coin_info$proof) == 0) 'No Available Information' else coin_info$proof)
            exchanges <- (if (nchar(coin_info$exchanges) == 0) 'No Available Information' else coin_info$exchanges)
            str <- paste("Coin Name: ", coin_info$coin_name)
            str2 <- paste("Coin Symbol: ", coin_info$symbol)
            str3 <- paste('Description: ', coin_info$description)
            str4 <- paste('Proof: ', proof)
            str5 <- paste('Exchanges to Trade on: ', exchanges)
            HTML(paste(str, str2, str3, str4, str5, sep = '<br/>'))
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
                all <- HTML(paste(str0, cutoff, sep = '<br/>'))
                for (row in 1:nrow(events_1)){
                    str <- paste("Coin Name: ", events_1[row, 'coin_name'])
                    str2 <- paste("Coin Symbol: ", events_1[row, 'coin_symbol'])
                    str3 <- paste('Event Title: ', events_1[row, 'title'])
                    str4 <- paste('Start Date: ', events_1[row, 'start'])
                    str5 <- paste('Description: ', events_1[row,'description'])
                    all <- HTML(paste(all, str, str2, str3, str4, str5, cutoff, sep = '<br/>'))
                }
                all
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
                all <- HTML(paste(str0, cutoff, sep = '<br/>'))
                for (row in 1:nrow(events)){
                    str <- paste("Coin Name: ", events[row,'coin_name'])
                    str2 <- paste("Coin Symbol: ", events[row, 'coin_symbol'])
                    str3 <- paste('Publication Date: ', events[row, 'publication_date'])
                    str4 <- paste('Start Date: ', events[row,'start'])
                    str5 <- paste('Description: ', events[row,'description'])
                    all <- HTML(paste(all, str, str2, str3, str4, str5, cutoff, sep = '<br/>'))
                }
                all
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
                all <- HTML(paste(str0, cutoff, sep = '<br/>'))
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
                all
            }
        }

    })

}

shinyApp(ui = ui, server = server)
