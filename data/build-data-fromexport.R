require(easyr)
require(qs)
begin()

fields = readRDS('raw-data/asec-clean-2019-2020/fields.RDS')
person = readRDS('raw-data/asec-clean-2019-2020/person.RDS')
household = readRDS('raw-data/asec-clean-2019-2020/person.RDS')
family = readRDS('raw-data/asec-clean-2019-2020/person.RDS')

if(!dir.exists('../app/data')) dir.create('../app/data')
for(i in names(person)) qsave(person[[i]], glue('../app/data/person-{i}'))
for(i in names(household)) qsave(household[[i]], glue('../app/data/household-{i}'))
for(i in names(family)) qsave(family[[i]], glue('../app/data/family-{i}'))

qsavem(fields, file = '../app/data/appdata')

