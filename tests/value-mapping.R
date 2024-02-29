require(easyr)
require(dplyr)
require(data.table)
begin()
setwd('..')

# read raw data.
person = fread('data/raw-data/2021/pppub21.csv')
household = fread('data/raw-data/2021/hhpub21.csv')
family = fread('data/raw-data/2021/ffpub21.csv')

# filter to one person.
set.seed(544)

iPERIDNUM = with(person, sample(x = PERIDNUM[year == 2023], size = 1))

iperson = person %>% filter(PERIDNUM == iPERIDNUM)
ifamily = family %>% filter(FFPOS == iperson$PF_SEQ, FH_SEQ == iperson$PH_SEQ)
ihousehold = household %>% filter(H_SEQ == iperson$PH_SEQ)