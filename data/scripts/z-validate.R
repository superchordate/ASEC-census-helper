# validate keys.
if(any(duplicated(cc(household$H_SEQ, household$FILEDATE)))) stop('Key failed.')
if(any(duplicated(cc(family$FFPOS, family$FH_SEQ, family$FILEDATE)))) stop('Key failed.')
if(any(duplicated(cc(person$FILEDATE)))) stop('Key failed.')

expect_equal(fields %>% filter(field == 'FTOTVAL') %>% pull(type), 'Numeric')
expect_equal(class(family$FTOTVAL), 'integer')
if('Alabama' %in% household$County) stop('Failed check: Alabama not a county.')

