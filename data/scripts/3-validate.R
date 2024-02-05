# validate keys.
if(any(duplicated(cc(household$H_SEQ, household$FILEDATE)))) stop('Key failed.')
if(any(duplicated(cc(family$FFPOS, family$FH_SEQ, family$FILEDATE)))) stop('Key failed.')
if(any(duplicated(cc(person$FILEDATE)))) stop('Key failed.')
