library(shiny)
library(shinythemes)
library(shinyjs)
library(dplyr)
library(knitr)
library(stringr)
library(shinydashboard)
library(rdrop2)


##############################################
# These first four functions are used to run the python research scripts,
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

run_through_links <- function(coin_name, coin_symbol, title, links_df, word1, word2){
    
    link_count <- 0
    for (row in 1:nrow(links_df)){
        link <- links_df[row, 'link']
        if (grepl(coin_name, link, ignore.case = TRUE) | grepl(coin_symbol, link, ignore.case = TRUE)) {
            link_count = link_count + 1
            if (grepl(word1, link) | grepl(word2, link)) {
                link_to_return <- link
                return (link_to_return)
            }
            else{
                link_to_return <- link
            }
        }
        if (link_count == 0){
            link_to_return <- paste('No Available Article on', title, sep = ' ')    
        }
    }
    return (link_to_return)
}

finalize_link <- function(link, name_of_site){
    if (!(grepl('No Available', link))) {
        link <- tags$a(href = link, paste(name_of_site, ' Description'))
    }
    return (link)
}


get_coin_of_day <- function(){
  current_day <- as.double(format(Sys.time(), '%d'))
  current_month <- as.double(format(Sys.time(), '%m'))
  coin_symbol <- price_information[current_day * current_month, 'symbol']
  return (coin_symbol)
}

get_coin_symbol <- function(input_coin_symbol){
    if (input_coin_symbol == 'Coin of the Day'){
        return (get_coin_of_day())
    }
    else{
        return (input_coin_symbol)
    }
}

coin_name_output <- function(coin_symbol){
    info = (price_information[price_information$symbol == coin_symbol, ])
    coin_name = (price_information[price_information$symbol == coin_symbol, 'name'])
    coin_symbol = paste('(', coin_symbol, ')')
    coin_price = paste(info$price_usd, ' (', info$percent_change_24h, ')')
    if ((as.numeric(substr(info$percent_change_24h, 1, 4))) >= 0) {
        coin_info = HTML(paste(tags$p(coin_name, style = "font-size: 170%;text-align: center;font-weight:bold"), 
                    tags$p(coin_symbol, style = 'font-size: 120%;text-align: center'), 
                    tags$p(coin_price, style = 'color : green;text-align:center; font-size:120%')))
    }
    else{
        coin_info = HTML(paste(tags$p(coin_name, style = "font-size: 170%;text-align: center"), 
                    tags$p(coin_symbol, style = 'font-size: 120%;text-align: center'), 
                    tags$p(coin_price, style = 'color : red;text-align:center; font-size:120%')))
    }
    return (coin_info)
}

official_links_output <- function(coin_symbol){
    coin_symbol <- get_coin_symbol(coin_symbol)
    website_link <- official_coin_site_link(coin_symbol)
    # twitter <- twitter_link(coin_symbol)
    # reddit <- reddit_link(coin_symbol)
    coin_info <- HTML(paste(
        tags$p('Official Links', style = 'text-align:center; font-size: 140%; font-weight:500'),
        tags$p(website_link, style = 'text-align:center; font-size:100%')
#        tags$p(twitter, style = 'text-align:center; font-size:100%'),
#        tags$p(reddit, style = 'text-align:center; font-size:100%')
    ))
    return (coin_info)
}


official_coin_site_link <- function(coin_symbol){
    coin_name <- (price_information[price_information$symbol == coin_symbol, 'name'])
    coin_info <- (coin_description_df[as.vector(coin_description_df$symbol) == coin_symbol, ])
    if (nrow(coin_info) == 0){
        coin_info <- (coin_description_df[as.vector(coin_description_df$symbol) == coin_name, ])
    }
    website_link <- coin_info$official_website
    if (!(grepl('Unknown', website_link))){
        website_link <- tags$a(href = website_link, 'Website')
    }
    else{
        website_link <- 'No Official Website'
    }
    return (website_link)
}

twitter_link <- function(coin_symbol){
    coin_name <- (price_information[price_information$symbol == coin_symbol, 'name'])
    coin_info <- (social_media_df[social_media_df$symbol == coin_symbol, ])
    if (nrow(coin_info) == 0){
        coin_info <- (social_media_df[social_media_df$coin_name == coin_name, ])
    }

    twitter_link <- coin_info$twitter
    if (!(grepl('Unknown', twitter_link))){
        twitter_link <- tags$a(href = twitter_link, 'Twitter')
    }
    else{
        twitter_link <- 'No Twitter Account'
    }
    return (twitter_link)

}

reddit_link <- function(coin_symbol){
    coin_name <- (price_information[price_information$symbol == coin_symbol, 'name'])
    coin_info <- (social_media_df[social_media_df$symbol == coin_symbol, ])
    if (nrow(coin_info) == 0){
        coin_info <- (social_media_df[social_media_df$coin_name == coin_name, ])
    }

    reddit_link <- coin_info$reddit
    if (!(grepl('Unknown', reddit_link))){
        reddit_link <- tags$a(href = reddit_link, 'Reddit')
    }
    else{
        reddit_link <- 'No Reddit Page'
    }

    return (reddit_link)

}

saveData <- function(data, outputDir) {
  data <- t(data)
  # Create a unique file name
  fileName <- sprintf("%s_%s.csv", as.integer(Sys.time()), digest::digest(data))
  # Write the data to a temporary file locally
  filePath <- file.path(tempdir(), fileName)
  write.csv(data, filePath, row.names = FALSE, quote = TRUE)
  # Upload the file to Dropbox
  drop_upload(filePath, path = outputDir)
}

loadData <- function(outputDir) {
  # Read all the files into a list
  print(outputDir)
  outputDir = paste("./data/", outputDir, sep = "")
  df <- read.csv(outputDir,  stringsAsFactors = FALSE)
  df
}

setwd('~/Documents/Crypto Shiny App/')
print('loading...')
coin_description_df <- loadData('initial_coin_research.csv')
print('loading...')
#social_media_df <- loadData('social_media_df')
print('loading...')
links_captainAlt <- loadData('captainAltCoin.csv')
print('loading...')
links_myCrypto <- loadData('myCryptopedia.csv')
print('loading...')
links_coinCentral <- loadData('coinCentral.csv')
print('loading...')
price_information <- loadData('price_information.csv')
symbols <- as.vector(loadData('symbols.csv')$symbol)
coinCalender <- loadData('coinCalender.csv')
coindar <- loadData('coinMarketCal.csv')
# links_blockonomi <- loadData('links_blockonomi')


ui <- dashboardPage(
    dashboardHeader(title = "Viceroy Research"),
    # dashboardHeader(title = tags$a(href='http://mycompanyishere.com',
    #                                 tags$img(src='logo.png')))
    dashboardSidebar(
        selectInput("coin_symbol", "Coin Symbol", choices = c('Coin of the Day', symbols)),
        sidebarMenu(
            menuItem('General Description', tabName = 'general'),
            menuItem('Initial Research Guide', tabName = 'research'),
            menuItem('Upcoming Events', tabName = 'events'),
            menuItem('Historical Data', tabName = 'historical')
        ),
        actionButton("dataReload", "Reload Data", width = '86%', style="color: #fff; background-color: #337ab7; border-color: #2e6da4")
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
            ),
            tabItem(tabName = 'historical',
                fluidRow(
                    column(2,
                        box(htmlOutput('coin_name4'), width = NULL, height = 200)
                    ),
                    column(4,
                        box(selectInput('start_date_select', 'Start Date', choices = c('Dates')),
                            selectInput('end_date_select', 'End Date', choices = c('Dates')),
                            selectInput('buy_indicator_select', 'Buy Indicator', choice = c('indicators')))
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

#        blockonomi_final <- run_through_links(coin_name, coin_symbol, 'Blockonomi',
#                                                links_blockonomi, 'blockonomi', 'blockonomi')
#        blockonomi_final <- finalize_link(blockonomi_final, 'Blockonomi')

        youtube <- paste('https://www.youtube.com/results?search_query=what+is+', coin_name_full, '+coin', sep = '')
        youtube_final <- tags$a(href = youtube, 'YouTube Explanations')

        tags$ul(
            tags$h2('Links for Initial Research'),
            tags$li(captainaltcoin_final),
            tags$li(mycryptopedia_final),
            tags$li(coinCentral_final),
            tags$li(youtube_final)
        )
        
    })

    output$price_info <- renderUI({
        coin_symbol <- get_coin_symbol(input$coin_symbol)
        info <- (price_information[price_information$symbol == coin_symbol, ])
        volume_usd_24h <- paste("24h Volume (USD): ", info$volume_usd_24h)
        market_cap <- paste("Market Cap: ", info$market_cap_usd)
        available_supply <- paste("Circulating Supply: ", info$available_supply)
        tags$div(
            volume_usd_24h, tags$br(),
            market_cap, tags$br(), 
            available_supply
        )
    })

    output$coin_name <- renderUI({
        coin_name_output(get_coin_symbol(input$coin_symbol))
    })

    output$coin_name2 <- renderUI({
        coin_name_output(get_coin_symbol(input$coin_symbol))
    })

    output$coin_name3 <- renderUI({
        coin_name_output(get_coin_symbol(input$coin_symbol))
    })

    output$coin_name4 <- renderUI({
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
        coin_info <- (coin_description_df[as.vector(coin_description_df$symbol) == coin_symbol, ])
        # Sometimes the symbols from the two APIs don't match up, so try and find the coin
        # another way. For example, coinMarketCap has IOTA symbol = MIOTA, whereas 
        # cryptocompare has the symbol = IOT
        if (nrow(coin_info) == 0){
            coin_name <- (price_information[as.vector(price_information$symbol) == coin_symbol, 'name'])
            coin_info <- (coin_description_df[as.vector(coin_description_df$coin_name) == coin_name, ])
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

        if (nrow(events_coinDar) + nrow(events_coinCal) == 0){
            'There are no published upcoming events for this coin.'
        }
        else{
            # Get dataframes ready to merge
            if (nrow(events_coinDar)){
                events_coinDar['website'] <- 'CoinDar'
                events_coinDar['title'] <- NA
                events_coinDar['description'] <- "See Source"
            }
            if (nrow(events_coinCal)){
              events_coinCal['website'] <- 'Coin Calender'
              events_coinCal['source'] <- NA
              
            }

            all_events <- rbind(events_coinDar, events_coinCal)
            cutoff <- '------------------------------------------'
            all <- ''
            for (row in 1:nrow(all_events)){
                event_title <- paste('Event Title: ', all_events[row, 'title'])
                start_date <- paste('Start Date: ', all_events[row, 'start'])
                source <- paste('Source: ', all_events[row, 'website'])
                link <- paste('Link: ', all_events[row, 'source'])
                if (all_events[row, 'website'] == 'CoinDar'){
                    description <- paste('Event Title: ', all_events[row, 'description'])
                    list_of_details <- tags$div(
                        tags$b(description),
                        tags$ul(
                            tags$li(start_date),
                            tags$li(source),
                            tags$li(tags$a(href = link, 'CoinDar'))
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
