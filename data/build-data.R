require(easyr)
require(glue)
require(tidyr)
require(pdftools)
require(data.table)
require(stringr)
require(qs)
require(lubridate)

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

qsavem(
  match_keys, fields,
  file = '../app/data/appdata'
)

# save output zip.
zipname = 'asec-clean-2019-2020'
if(!file.exists(glue('out/{zipname}.zip'))){
  if(!dire.exists(glue('out/{zipname}'))) dir.create(glue('out/{zipname}'))
  w(fields, glue('out/{zipname}/fields.csv'))
  w(family, glue('out/{zipname}/family.csv'))
  w(household, glue('out/{zipname}/household.csv'))
  w(person, glue('out/{zipname}/person.csv'))
  zip(zipfile = glue('out/{zipname}'), files = glue('out/{zipname}'))
  file.remove(list.files(glue('out/{zipname}'), full.names = TRUE))
}
