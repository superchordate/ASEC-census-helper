# Define server logic required to draw a histogram
server = function(input, output, session) {
  
  # run files in server/ folder.
  for(i in list.files('server', pattern = '[.][Rr]', recursive = TRUE, full.names = TRUE )) source( i, local = TRUE )
  rm(i)
   
}
