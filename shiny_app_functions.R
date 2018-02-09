

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
    twitter <- twitter_link(coin_symbol)
    reddit <- reddit_link(coin_symbol)
    coin_info <- HTML(paste(
        tags$p('Official Links', style = 'text-align:center; font-size: 140%; font-weight:500'),
        tags$p(website_link, style = 'text-align:center; font-size:100%'),
        tags$p(twitter, style = 'text-align:center; font-size:100%'),
        tags$p(reddit, style = 'text-align:center; font-size:100%')
    ))
    return (coin_info)
}


official_coin_site_link <- function(coin_symbol){
    coin_name <- (price_information[price_information$symbol == coin_symbol, 'name'])
    coin_info <- (coin_description_df[coin_description_df$symbol == coin_symbol, ])
    if (nrow(coin_info) == 0){
        coin_info <- (coin_description_df[coin_description_df$coin_name == coin_name, ])
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



