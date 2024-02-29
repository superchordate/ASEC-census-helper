require(easyr)
require(dplyr)
require(data.table)
begin()

# read raw data.
person = fread('data/raw-data/asec-clean-2019-2023/person.csv')
#household = fread('data/raw-data/asec-clean-2019-2023/household.csv')
#family = fread('data/raw-data/asec-clean-2019-2023/family.csv')
fields = fread('data/raw-data/asec-clean-2019-2023/fields.csv')

# filter to one person's data.
set.seed(544)
iPERIDNUM = with(person, sample(x = PERIDNUM[year == 2023], size = 1))
iperson  = person %>% filter(PERIDNUM == iPERIDNUM)
#ifamily = family %>% filter(FFPOS == iperson$PF_SEQ, FH_SEQ == iperson$PH_SEQ, year == 2023)
#ihousehold = household %>% filter(H_SEQ == iperson$PH_SEQ, year == 2023)

# combine info from fields
dt = iperson %>% 
  mutate_all(as.character) %>% 
  melt(id.vars = 'year', variable.name = 'Field') %>%
  dcast.data.table(Field ~ year)

dt %<>% inner_join(
  fields %>% select(Field, Description, Topic, Subtopic),
  by = 'Field'
) %>%
  relocate(Description)

View(dt)
