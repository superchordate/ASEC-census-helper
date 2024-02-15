require(easyr)
require(glue)
require(tidyr)
require(pdftools)
require(data.table)
require(stringr)
require(qs)
require(lubridate)
require(zoo)
require(progress)
require(testthat)

begin()

filesat = 'raw-data'
forkaggle = TRUE

runfolder('scripts')

file.remove(list.files('../app/data', full.names = TRUE))

# create the folder and clear prior data. 
if(!dir.exists('../app/data')) dir.create('../app/data')
file.remove(list.files('../app/data', full.names = TRUE))

# save new files, one for each column.
for(i in names(person)) qsave(person[[i]], glue('../app/data/person-{i}'))
for(i in names(household)) qsave(household[[i]], glue('../app/data/household-{i}'))
for(i in names(family)) qsave(family[[i]], glue('../app/data/family-{i}'))

# save new files, one for each column.
qsavem(fields, file = '../app/data/appdata')

# save output zip.
zipname = 'asec-clean-2019-2023'
if(!file.exists(glue('out/{zipname}.zip'))){
  
  if(!dir.exists(glue('out/{zipname}'))) dir.create(glue('out/{zipname}'))
  
  if(forkaggle){
    
    w(fields, glue('out/{zipname}/fields.csv'))
    w(family, glue('out/{zipname}/family.csv'))
    w(household, glue('out/{zipname}/household.csv'))
    w(person, glue('out/{zipname}/person.csv'))
    
  } else {
    
    saveRDS(fields, glue('out/{zipname}/fields.RDS'))
    saveRDS(family, glue('out/{zipname}/family.RDS'))
    saveRDS(household, glue('out/{zipname}/household.RDS'))
    saveRDS(person, glue('out/{zipname}/person.RDS'))
    
  }
  
  # we have to move into out/ before we zip to avoid that folder being included in the zip.
  zip(zipfile = glue('out/{zipname}'), files = list.files(glue('out/{zipname}'), full.names = TRUE), flags = '-r9Xj') # https://stackoverflow.com/questions/51844607/zip-files-without-including-parent-directories
  
  file.remove(list.files(glue('out/{zipname}'), full.names = TRUE))
  
}
