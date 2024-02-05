if(!cache.ok(4)){
  
  # add sample values to fields
  fields$sample = 'sample'  
  for(irow in 1:nrow(fields)){

    itable = tolower(fields$recordtype[irow])
    if(is.na(itable)) browser()
    icol = fields$field[irow]

    if(is.numeric(get(itable)[[icol]])){
      ivalues = 'Numeric'
    } else {
      ivalues = sort(table(get(itable)[, c(icol), with = FALSE]))
      ivalues = tail(names(ivalues), 3)
    }

    if(any(is.na(ivalues))) browser()
    fields$sample[irow] <- cc(ivalues, sep = '; ')

    rm(itable, icol, ivalues, irow)
  }
    
  save.cache(fields, values, person, household, family, match_keys)

}