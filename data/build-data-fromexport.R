require(easyr)
require(qs)
require(glue)
begin()

fields = readRDS('raw-data/asec-clean-2019-2023/fields.RDS')
person = readRDS('raw-data/asec-clean-2019-2023/person.RDS')
household = readRDS('raw-data/asec-clean-2019-2023/household.RDS')
family = readRDS('raw-data/asec-clean-2019-2023/family.RDS')

# create the folder and clear prior data. 
if(!dir.exists('../app/data')) dir.create('../app/data')
file.remove(list.files('../app/data', full.names = TRUE))

# save new files, one for each column.
for(i in names(person)) qsave(person[[i]], glue('../app/data/person-{i}'))
for(i in names(household)) qsave(household[[i]], glue('../app/data/household-{i}'))
for(i in names(family)) qsave(family[[i]], glue('../app/data/family-{i}'))

# save app-specific data.
qsavem(fields, file = '../app/data/appdata')

