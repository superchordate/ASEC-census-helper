if(!cache.ok(4)){
  
  # add sample values to fields
  fields$sample = 'sample'  
  for(irow in 1:nrow(fields)){

    itable = tolower(fields$recordtype[irow])
    if(is.na(itable)) browser()
    icol = fields$field[irow]

    ivalues = sort(table(get(itable)[, c(icol), with = FALSE]))
    ivalues = tail(names(ivalues), 3)

    if(any(is.na(ivalues))){
      warning('Found NA sample values. Entering browser.')
      browser()
    }
    
    fields$sample[irow] <- cc(ivalues, sep = '; ')

    rm(itable, icol, ivalues, irow)
  }

}