require(easyr)
require(shiny)
require(data.table)
require(forcats)
require(glue)
require(lubridate)
require(purrr)
require(DT)
require(qs)
require(shinyjs)
require(stringr)

begin()

enableBookmarking(store = "url")

islocal = Sys.getenv('SHINY_PORT') == ""

# read global files.
for(i in list.files('global', pattern = '[.][Rr]', recursive = TRUE, full.names = TRUE )) source( i, local = TRUE )
rm(i)

qload('data/appdata')

# dev views.
view = 'production' # production, previewdata
