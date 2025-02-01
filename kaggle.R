require(easyr)
require(dplyr)
require(data.table)
require(htmltools)
begin()

# read raw data.
person = fread('data/.outputasec-clean-2019-2023/person.csv')
household = fread('data/.outputasec-clean-2019-2023/household.csv')
family = fread('data/.outputasec-clean-2019-2023/family.csv')
fields = fread('data/.outputasec-clean-2019-2023/fields.csv')

# filter to one person's data.
set.seed(544)
iPERIDNUM = with(person, sample(x = `22-Digit Unique Person Identifier (PERIDNUM)`[year == 2023], size = 1))
iperson  = person %>% filter(`22-Digit Unique Person Identifier (PERIDNUM)` == iPERIDNUM)
ifamily = family %>% filter(
  `Unique Family Identifier. This Field Plus Fh_seq Results In A Unique Family Number For The File. (FFPOS)` == iperson$`Pointer To The Sequence Number Of Family Record In Household (Related Subfamilies Point To Primary Family) (PF_SEQ)`, 
  `Household Sequence Number. Matches H_seq For Same Household (FH_SEQ)` == iperson$`Household Seq Number (PH_SEQ)`, year == 2023)
ihousehold = household %>% filter(`Household Sequence Number (H_SEQ)` == iperson$`Household Seq Number (PH_SEQ)`, year == 2023)

# set up a function to clean and display the data:
showdata = function(x){
  
  # combine info from fields
  dt = x %>% 
    mutate_all(as.character) %>% 
    melt(id.vars = 'year', variable.name = 'Description') %>%
    dcast.data.table(Description ~ year)
  
  dt %<>% 
    left_join(
      fields %>% filter(`Record Type` == x$recordtype[1]) %>% select(Description, Topic, Subtopic),
      by = 'Description'
    ) %>%
    relocate(Description, Subtopic, Topic) %>%
    mutate(Description = as.character(Description))
  
  # filter to only readable fields. 
  dt %<>% filter(
    Topic != 'Record Identifiers', # not needed for display.
    !grepl('Not In Universe', `2023`), # this information is not useful.
    Subtopic != 'Allocation Flags' # not intuitive for laypeople.
  )

  # return readable HTML.
  tags$ul(lapply(split(dt, dt$Topic), function(i){
    tags$li(
      i$Topic[1],
      tags$ul(lapply(split(i, 1:nrow(i)), function(j){
        tags$li(
          paste(c(j$Description, j$`2023`), collapse = ': ')
        )
      }))
    )
  }))
  
}

showdata(iperson)

