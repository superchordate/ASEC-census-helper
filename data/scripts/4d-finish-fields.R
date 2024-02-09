if(!cache.ok(4)){

  # better date format.
  household$FILEDATE %<>% mdy()
  person$FILEDATE %<>% mdy()
  family$FILEDATE %<>% mdy()

  # intuitive sorting. 
  household %<>% arrange(H_IDNUM, FILEDATE)
  person %<>% arrange(PERIDNUM, FILEDATE)
  family %<>% arrange(FH_SEQ, FFPOS, FILEDATE)

  # remove joining and metadata fields that we'll always use. 
  fields %<>% filter(
    field %ni% c('PF_SEQ', 'PH_SEQ', 'FILEDATE', 'FH_SEQ', 'FFPOS', 'H_SEQ'),
    topic %ni% 'Record Identifiers',
    !grepl('_ID$', field),
    !grepl('^Topcde flag for ', desc)
  )

  fields = distinct(fields) %>% as.data.table()

  # add metric fields. 
  fields$complete = NA
  fields$num_values = NA
  fields$type = NA
  for(i in 1:nrow(fields)){
    x = get(tolower(fields$recordtype[i]))[[fields$field[i]]]
    fields$complete[i] <- mean(!is.na(x))
    fields$num_values[i] <- sum(!duplicated(x))
    fields$type[i] <- fifelse(is.numeric(x), 'Numeric', 'Multivalued')
    rm(i, x)
  }

  fields %<>% mutate(table_field = cc(recordtype, field, sep = '-'))
  fields %<>% arrange(desc(complete), num_values)
  fields %<>% relocate(field, desc, complete, num_values, sample)

  fields %<>% filter(complete > 0.05)

  # select initial defaults.
  fields$default = fields$table_field %in% c(
    'Household-State', 
    'Household-County',
    'Family-FKINDEX',
    'Household-H_LIVQRT',
    'Person-HEA',
    'Person-PTOT_R',
    'Person-A_AGE',
    'Person-A_SEX',
    'Person-NOW_COV',
    'Person-A_MARITL',
    'Person-A_MJOCC',
    'Person-​PTOTVAL',
    # numeric
    'Person-FEDTAX_AC',
    'Person-A_USLHRS',

  )

  fields %<>% select(-c(values, table_field)) # these are not needed by the app. 
  fields$id = 1:nrow(fields)
    
  save.cache(fields, values, person, household, family, match_keys)

}