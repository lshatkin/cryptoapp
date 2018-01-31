library(rsconnect)
rsconnect::setAccountInfo(name='viceroyholdings', 
                            token='884664BFCAEFCD7D13D8EA1C0BEF1E96',
                            secret='mxdU46dN7EsXrNAle4x2ZCfnrok5BrtPATIN5SWk')
rsconnect::deployApp('~/Desktop/crypto/research_infrastructure', account = 'viceroyholdings')