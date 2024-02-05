# Define server logic required to draw a histogram
server = function(input, output, session) {
  
  # run files in server/ folder.
  dofiles = list.files('server', pattern = '[.][Rr]', recursive = TRUE, full.names = TRUE )
  dofiles = dofiles[order(grepl('/[^.]+/', dofiles))] # put source/ home files first.
  for(i in dofiles) source( i, local = TRUE )
  rm(i)
   
}
