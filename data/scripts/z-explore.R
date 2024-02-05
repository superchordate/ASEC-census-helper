if(F){
  
  fields %>% 
    filter(
      field %in% names(person_raw),
      subtopic %ni% c(
        'SubMatch Keys', 'SubRecord Type', 'SubRecord Pointers', 'SubBasic CPS', 'SubASEC Supplement',
        'SubAllocation Flags'
      )
    ) %>%
    View()
  
}