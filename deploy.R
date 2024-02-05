require(easyr)
require(rsconnect)
begin()

source('secrets', local = TRUE)
deployApp(appDir = 'app/', appName = 'ASEC-census-helper')
