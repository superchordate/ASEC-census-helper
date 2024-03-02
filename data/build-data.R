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
forkaggle = TRUE # create output for Kaggle: pretty field names and write CSV instead of RDS.

runfolder('scripts')

# create the folder and clear prior data. 
if(!dir.exists('../app/data')) dir.create('../app/data')
zipname = glue('asec-clean-{min(household$year)}-{max(household$year)}')
file.remove(list.files('../app/data', full.names = TRUE))

# save app files.
qsavem(fields, file = '../app/data/appdata')
for(i in names(person)) qsave(person[[i]], glue('../app/data/person-{i}'))
for(i in names(household)) qsave(household[[i]], glue('../app/data/household-{i}'))
for(i in names(family)) qsave(family[[i]], glue('../app/data/family-{i}'))

# save zipped data.
 
if(!dir.exists(glue('out/{zipname}'))) dir.create(glue('out/{zipname}'))
file.remove(list.files(glue('out/{zipname}'), full.names = TRUE))
  
if(forkaggle){

  # easier-to-read fields. 
  fields %<>% 
    mutate(year = max(household$year)) %>%
    select(
      Description = desc,
      Subtopic = subtopic,
      Topic = topic,
      `Record Type` = recordtype,
      Year = year,
      ID = field,
      Type = type,
      `Sample Values` = sample,
      `% Complete` = complete,
      `# Distinct Values` = num_values
  )
  
  # use pretty names with the ID in parenthesis.
  fields$Description %<>% str_to_title()
  fields$Description = cc(fields$Description, ' (', fields$ID, ')')

  prettynames = function(table){
    
    descriptions = sapply(
      names(get(table)),
      function(x) if(x %in% fields$ID){
        fields %>% filter(ID == x, `Record Type` == tools::toTitleCase(table)) %>% pull(Description)
      } else {
        x
    })
    
    badvals = unique(descriptions[duplicated(descriptions)])
    if(length(badvals) > 0) stop(glue('prettynames [{table}]: bad values [{cc(badvals, sep = ", ")}].'))
    
    return(descriptions)
    
  }
  names(family) = prettynames('family')
  names(household) = prettynames('household')
  names(person) = prettynames('person')
  
  # write CSVs.
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
  
# https://stackoverflow.com/questions/51844607/zip-files-without-including-parent-directories
zip(zipfile = glue('out/{zipname}'), files = list.files(glue('out/{zipname}'), full.names = TRUE), flags = '-r9Xj')
