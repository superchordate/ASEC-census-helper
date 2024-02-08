require(easyr)
require(shiny)
require(data.table)
require(forcats)
require(glue)
require(reactable)
require(qs)
require(shinydashboard)
require(shinyjs)

begin()

enableBookmarking(store = "url")

islocal = Sys.getenv('SHINY_PORT') == ""

# read global files.
for(i in list.files('global', pattern = '[.][Rr]', recursive = TRUE, full.names = TRUE)) source(i, local = TRUE)
rm(i)

qload('data/appdata')

