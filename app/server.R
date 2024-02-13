server = function(input, output, session) {
  dofiles = list.files('server', pattern = '[.][Rr]', recursive = TRUE, full.names = TRUE)
  dofiles = dofiles[order(grepl('/[^.]+/', dofiles))]
  for(i in dofiles) source( i, local = TRUE )
  rm(i)   
}
