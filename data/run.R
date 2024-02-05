require(easyr)
require(glue)
require(tidyr)
require(pdftools)
require(data.table)
require(stringr)
require(qs)

begin()

filesat = 'raw-data'

runfolder('scripts')

file.remove(list.files('../app/data', full.names = TRUE))

#qsave(household, '../app/data/household', nthreads = 2)
#qsave(family, '../app/data/family', nthreads = 2)
if(!dir.exists('../app/data')) dir.create('../app/data')
for(i in names(person)) qsave(person[[i]], glue('../app/data/person-{i}'))
for(i in names(household)) qsave(household[[i]], glue('../app/data/household-{i}'))
for(i in names(family)) qsave(family[[i]], glue('../app/data/family-{i}'))

fields = distinct(fields)
qsavem(
  match_keys, fields,
  file = '../app/data/appdata'
)
