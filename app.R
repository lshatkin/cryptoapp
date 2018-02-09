library(shiny)
library(shinythemes)
library(shinyjs)
library(dplyr)
library(xtable)
library(knitr)
library(shinythemes)
library(stringr)
library(shinydashboard)
source('shiny_app_functions.R')
coin_description_df <- read.csv('initial_coin_research.csv', stringsAsFactors=F)
social_media_df <- read.csv('social_media_links.csv', stringsAsFactors = F)
price_information <- read.csv('price_information.csv', stringsAsFactors = F)
coinCalender <- read.csv('coinCalender.csv', stringsAsFactors = F)
coinMarketCal <- read.csv('coinMarketCal.csv', stringsAsFactors = F)
coindar <- read.csv('coindar.csv', stringsAsFactors = F)
links_captainAlt <- read.csv('captainAltCoin.csv', stringsAsFactors = F)
links_myCrypto <- read.csv('myCryptopedia.csv', stringsAsFactors = F)
links_coinCentral <- read.csv('coinCentral.csv', stringsAsFactors = F)
links_blockonomi <- read.csv('blockonomi.csv', stringsAsFactors = F)

# run_calender_scraper()
# run_coin_description()
# run_price_info()


##############################################
# These first four functions are used to run the python research scripts,
# and overwrite the current CSV files that are saved. The 'Price Info' script
# should probably be run often (we want current prices), the 'Calender Scraper'
# can be run once a day or so, and the coin description probably does not need
# to be run very often. Will stay the same.
##############################################


ui <- dashboardPage(

    dashboardHeader(title = "Viceroy Research"),
    dashboardSidebar(
        selectInput("coin_symbol", "Coin Symbol", choices = c('Coin of the Day', price_information$symbol)),
        sidebarMenu(
            menuItem('General Description', tabName = 'general'),
            menuItem('Initial Research Guide', tabName = 'research'),
            menuItem('Upcoming Events', tabName = 'events')
        )
    ),
    dashboardBody(
        # Change background color to white
        tags$head(tags$style(HTML('
          .content-wrapper,
            .right-side {
            background-color: #ffffff;
            }'))
        ),
        tabItems(
            tabItem(tabName = 'general',
                fluidRow(
                    column(2,
                        box(htmlOutput('coin_name'), width = NULL, height = 200),
                        box(htmlOutput('main_links'), width = NULL, height = 200)
                    ),
                    column(10,
                        box(htmlOutput('price_info'), width = NULL, height = 200),
                        box(htmlOutput('general'), width = NULL)    
                    )
                )
            ),
            tabItem(tabName = 'research',
                fluidRow(
                    column(2,
                        box(htmlOutput('coin_name2'), width = NULL, height = 200),
                        box(htmlOutput('main_links2'), width = NULL, height = 200)
                    ),
                    column(10,
                        box(htmlOutput('links'), width = NULL, height = 200)
                    )
                )
            ),
            tabItem(tabName = 'events',
                fluidRow(
                    column(2,
                        box(htmlOutput('coin_name3'), width = NULL, height = 200),
                        box(htmlOutput('main_links3'), width = NULL, height = 200)
                    ),
                    column(10,
                        box(div(style = 'overflow-x: scroll', htmlOutput('calender')), width = NULL)
                    )
                )
            )
        )
    )   
)



server <- function(input, output) {
    

    output$links <- renderUI({

        coin_symbol <- get_coin_symbol(input$coin_symbol)
        coin_name_full <- price_information[price_information$symbol == coin_symbol, 'name']
        coin_name <- word(coin_name_full, 1)
        
        captainaltcoin_final <- run_through_links(coin_name, coin_symbol, 'Captain Altcoin', 
                                                    links_captainAlt, 'cryptocurrency', 'what-is')
        captainaltcoin_final <- finalize_link(captainaltcoin_final, 'Captain Altcoin')

        mycryptopedia_final <- run_through_links(coin_name, coin_symbol, 'My Cryptopedia', 
                                                    links_myCrypto, 'crypto', 'crypto')
        mycryptopedia_final <- finalize_link(mycryptopedia_final, 'My Cryptopedia')

        coinCentral_final <- run_through_links(coin_name, coin_symbol, 'Coin Central', 
                                                links_coinCentral, 'guide', 'what-is')
        coinCentral_final <- finalize_link(coinCentral_final, 'Coin Central')

        blockonomi_final <- run_through_links(coin_name, coin_symbol, 'Blockonomi',
                                                links_blockonomi, 'blockonomi', 'blockonomi')
        blockonomi_final <- finalize_link(blockonomi_final, 'Blockonomi')

        youtube <- paste('https://www.youtube.com/results?search_query=what+is+', coin_name_full, '+coin', sep = '')
        youtube_final <- tags$a(href = youtube, 'YouTube Explanations')

        tags$ul(
            tags$h2('Links for Initial Research'),
            tags$li(captainaltcoin_final),
            tags$li(mycryptopedia_final),
            tags$li(coinCentral_final),
            tags$li(blockonomi_final),
            tags$li(youtube_final)
        )
        
    })

    output$price_info <- renderUI({
        coin_symbol <- get_coin_symbol(input$coin_symbol)
        info <- (price_information[price_information$symbol == coin_symbol, ])
        price_btc <- paste("Price BTC: ", info$price_btc)
        volume_usd_24h <- paste("24h Volume (USD): ", info$volume_usd_24h)
        market_cap <- paste("Market Cap: ", info$market_cap_usd)
        available_supply <- paste("Circulating Supply: ", info$available_supply)
        tags$div(
            price_btc, tags$br(), 
            volume_usd_24h, tags$br(),
            market_cap, tags$br(), 
            available_supply
        )
    })

    output$tweets <- renderUI({'Coming soon...'})

    output$coin_name <- renderUI({
        coin_name_output(get_coin_symbol(input$coin_symbol))
    })

    output$coin_name2 <- renderUI({
        coin_name_output(get_coin_symbol(input$coin_symbol))
    })

    output$coin_name3 <- renderUI({
        coin_name_output(get_coin_symbol(input$coin_symbol))
    })

    output$main_links <- renderUI({
        official_links_output(input$coin_symbol)
    })

    output$main_links2 <- renderUI({
        official_links_output(input$coin_symbol)
    })

    output$main_links3 <- renderUI({
        official_links_output(input$coin_symbol)
    })
    output$general <- renderUI({

        coin_symbol <- get_coin_symbol(input$coin_symbol)
        coin_info <- (coin_description_df[coin_description_df$symbol == coin_symbol, ])
        # Sometimes the symbols from the two APIs don't match up, so try and find the coin
        # another way. For example, coinMarketCap has IOTA symbol = MIOTA, whereas 
        # cryptocompare has the symbol = IOT
        if (nrow(coin_info) == 0){
            coin_name <- (price_information[price_information$symbol == coin_symbol, 'name'])
            coin_info <- (coin_description_df[coin_description_df$coin_name == coin_name, ])
        }
        description <- (if (nchar(coin_info$description) == 0) 'No Available Information' else coin_info$description)
        description <- HTML(paste(tags$b('Description: '), description))
        proof <- (if (nchar(coin_info$proof) == 0) 'No Available Information' else coin_info$proof)
        proof <- HTML(paste(tags$b('Proof: '), proof))
        exchanges <- (if (nchar(coin_info$exchanges) == 0) 'No Available Information' else coin_info$exchanges)
        exchanges <- HTML(paste(tags$b('Exchanges Traded On: '), exchanges))

        tags$div(
            description, tags$br(), tags$br(),
            proof, tags$br(), tags$br(),
            exchanges
        )
    })


    output$calender <- renderUI({

        coin_symbol <- get_coin_symbol(input$coin_symbol)
        coin_name <- (price_information[price_information$symbol == coin_symbol, 'name'])

        events_coinCal <- coinCalender[coinCalender['coin_symbol'] == coin_symbol, ]
        if (nrow(events_coinCal) == 0){events_coinCal <- (coinCalender[coinCalender['coin_name'] == coin_name, ])}

        events_coinDar <- coindar[coindar['coin_symbol'] == coin_symbol, ]
        if (nrow(events_coinDar) == 0){events_coinDar <- (coindar[coindar['coin_name'] == coin_name, ])}

        events_coinMarket <- coinMarketCal[coinMarketCal['coin_symbol'] == coin_symbol, ]
        if (nrow(events_coinMarket) == 0){events_coinMarket <- (coinMarketCal[coinMarketCal['coin_name'] == coin_name, ])}
        

        if ((nrow(events_coinMarket) + nrow(events_coinDar) + nrow(events_coinCal)) == 0){
            'There are no published upcoming events for this coin.'
        }
        else{
            # Get dataframes ready to merge
            if (nrow(events_coinMarket)) {events_coinMarket['website'] <- 'Coin Market Cal'}
            if (nrow(events_coinDar)){
                events_coinDar['website'] <- 'CoinDar'
                events_coinDar['title'] <- NA
            }
            if (nrow(events_coinCal)){
            events_coinCal['website'] <- 'Coin Calender'
            events_coinCal['publication_date'] <- NA
            }

            all_events <- rbind(rbind(events_coinMarket, events_coinDar), events_coinCal)
            cutoff <- '------------------------------------------'
            all <- ''
            for (row in 1:nrow(all_events)){
                event_title <- paste('Event Title: ', all_events[row, 'title'])
                start_date <- paste('Start Date: ', all_events[row, 'start'])
                publication_date <- paste('Publication Date: ', all_events[row, 'publication_date'])
                source <- paste('Source: ', all_events[row, 'website'])
                if (all_events[row, 'website'] == 'CoinDar'){
                    description <- paste('Event Title: ', all_events[row, 'description'])
                    list_of_details <- tags$div(
                        tags$b(description),
                        tags$ul(
                            tags$li(start_date),
                            tags$li(publication_date),
                            tags$li(source)
                        )
                    )
                    all <- HTML(paste(all, list_of_details))
                }
                else{
                    description <- paste('Description: ', all_events[row, 'description'])
                    list_of_details <- tags$div(
                        tags$b(event_title),
                        tags$ul(
                            tags$li(description),
                            tags$li(start_date),
                            tags$li(publication_date),
                            tags$li(source)
                        )
                    )
                    all <- HTML(paste(all, list_of_details))                 
                }

            }

            tags$div(
                tags$h1('Upcoming Events'),
                tags$h5('Information comes from the following websites:'),
                tags$ul(
                    tags$li(tags$a(href = 'https://coindar.org/en', 'CoinDar')),
                    tags$li(tags$a(href = 'http://www.coincalendar.info/', 'Coin Calendar')),
                    tags$li(tags$a(href = 'https://coinmarketcal.com/', 'Coin Market Cal'))
                ),
                all
            )

        }
    })

}



shinyApp(ui = ui, server = server)
