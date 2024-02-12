# parse the data dictionary PDF.
if(!cache.ok(2)){

    # process the PDF data dictionary into something we can use. 
    # loop over years. 
    for(i in seq_along(dt)){
      
      # combine pages and lines. 
      pdfdt = bind_rows(
        lapply(
          seq_along(dt[[i]]$dictionary), 
          function(j) dt[[i]]$dictionary[[j]] %>% mutate(pg = j))
      ) %>%
        arrange(pg, y, x)

      # identify the cutoff between left and right columns. 
      # this will be between the second "Variable" and the first "Range"
      # subtract a few to allow for slight variations. 
      leftrightcutoff = pdfdt$x[grep('^Variable$', pdfdt$text)[2]] - 5
      pdfdt$side = fifelse(pdfdt$x < leftrightcutoff, 0, 1)
      pdfdt %<>% arrange(pg, side, y, x)      
      
      # drop entire rows prior to splitting by side. 
      lines = pdfdt %>% 
        group_by(pg, y) %>% 
        summarize(text = trimws(cc(text, sep = ' ')), .groups = 'drop') %>% 
        arrange(pg, y)
      
      lines %<>% filter(!grepl('ASEC.+Public Use Data Dictionary', text))
      lines %<>% filter(!grepl('Variable Length Position Range', text))
      lines %<>% filter(!grepl('^Data Dictionary', text)) # footers
      
      # extract record type. 
      lines$recordtype = gsub('Record Type: ', '', str_extract(lines$text,'Record Type: [^ ]+'))
      lines$recordtype %<>% zoo::na.locf()
      lines %<>% filter(!grepl('^Record Type:', text))
      
      # add record type and remove rows from pdfdt.
      pdfdt %<>% inner_join(lines %>% select(pg, y), by = c('pg', 'y'))
      pdfdt %<>% jrepl(lines, by = c('pg', 'y'), replace.cols = 'recordtype')
      
      # now we can get lines organized by left vs right. 
      lines = pdfdt %>% 
        group_by(recordtype, pg, side, y) %>% 
        summarize(text = cc(text, sep = ' '), .groups = 'drop') %>% 
        arrange(pg, side, y)
      
      #  add topic.
      lines$topic = gsub('^Topic: ', '', str_extract(lines$text,'^Topic: .+'))
      lines$topic %<>% zoo::na.locf()
      lines %<>% filter(!grepl('^Topic:', text))
      
      lines$subtopic = gsub('^SubTopic: ', '', str_extract(lines$text,'^SubTopic: .+'))
      lines$subtopic %<>% zoo::na.locf()
      lines %<>% filter(!grepl('^SubTopic:', text))
      
      # in some cases, the information is on a line before the field name.
      badsort = grep('^[0-9]+ [0-9]+ \\(.*\\)', lines$text)
      for(j in badsort){
        lines$text[badsort] = cc(lines$text[badsort + 1], lines$text[badsort], sep = ' ')
        lines$text[badsort + 1] <- ''
      }
      
      # similar with values. 
      badsort = grep('^Values:$', lines$text)
      for(j in badsort){
        lines$text[badsort] = cc(lines$text[badsort], lines$text[badsort - 1], sep = ' ')
        lines$text[badsort - 1] <- ''
      }
      lines$text %<>% trimws()
      
      # process each column.
      fields_start_at = grep('^[^ ]+ [0-9]+ [0-9]+ \\(.*\\)', lines$text)
      fields_varlenpos = strsplit(lines$text, ' ')
      fields = lapply(seq_along(fields_start_at), function(j){
        
        startat = fields_start_at[j]
        endat = ifelse(j < length(fields_start_at), fields_start_at[j + 1] - 1, nrow(lines))
        jdt = lines[startat:endat, ]
        
        varlenpos = fields_varlenpos[[startat]]
        
        field = data.frame(
          field = toupper(varlenpos[1]), length = varlenpos[2], position = varlenpos[3], range = varlenpos[4],
          recordtype = jdt$recordtype[1],
          topic = jdt$topic[1], subtopic = jdt$subtopic[1]
        )
        
        start_values = grep('^Values', jdt$text)
        start_universe = grep('^Universe', jdt$text)
        
        jdt$text = gsub('^(Values|Universe):? ?', '', jdt$text)
        
        # there are some malformed values, in this case we will register a read error and move on.
        if(length(start_values) > 0 && length(start_universe) > 0){
          
          field$desc = cc(jdt$text[-c(1, start_values:nrow(jdt))], sep = ' ')
          field$universe = cc(jdt$text[start_universe:nrow(jdt)], sep = '')
          field$values = cc(jdt$text[start_values:(start_universe - 1)], sep = '|')
          
        } else if(length(start_universe) == 0 && length(start_values) == 0){
          
          field$desc = cc(jdt$text, sep = ' ')
          field$universe = 'read-error'
          field$values = 'read-error'
          
        } else if(length(start_universe) == 0){
          
          field$desc = cc(jdt$text[-c(1, start_values:nrow(jdt))], sep = ' ')
          field$universe = 'read-error'
          field$values = cc(jdt$text[start_values:nrow(jdt)], sep = '|')
          
        } else if(length(start_values) == 0){
          
          field$desc = cc(jdt$text[-c(1, start_universe:nrow(jdt))], sep = ' ')
          field$universe = cc(jdt$text[start_universe:nrow(jdt)], sep = '')
          field$values = 'read-error'
          
        }
        
        field$raw_dictionary = cc(jdt$text, sep = '\n')
        
        return(field)
        
      })
      fields %<>% rbindlist()
      fields$desc = trimws(gsub(' +', ' ', fields$desc))
      
      # remove allocation flags. 
      fields %<>% filter(!grepl('llocation flag', desc))

      # save to list.
      dt[[i]]$fields = fields
      
      # we'll also want a set of unique mappings.
      value_map = fields %>% 
        distinct(recordtype, field, values) %>% 
        filter(grepl('=[^)]+$', values)) # prevent = in parenthesis.

      value_map_split = strsplit(value_map$values, '\\|')

      value_map = lapply(seq_len(nrow(value_map)), function(j){
        data.frame(
          recordtype = value_map$recordtype[j], 
          field = value_map$field[j], 
          values = value_map$values[j], 
          from = gsub(' ?=.+$', '', value_map_split[[j]]),
          to = gsub('^[^=]+ ?', '', value_map_split[[j]])
        )
      }) %>% rbindlist()
      
      notamap = value_map %>% filter(grepl('-', from)) %>% pull(values)
      notamap %<>% c(
        grep('^0.+dollar amount', value_map$values, value = TRUE),
        grep('^0 = niu\\|1 = one', value_map$values, value = TRUE),
        grep(':', value_map$values, value = TRUE),
        grep('opcoded', value_map$values, value = TRUE) # we are ignoring topcoded for now.        
      )
      
      value_map %<>% 
        filter(values %ni% notamap) %>%
        mutate(to = gsub(' ?=', '', to))
      
      # add categories. 
      value_map$category = NA
      iscat = which(grepl('[A-z]', value_map$from) & value_map$from != 'added')
      value_map$category[iscat] <- value_map$from[iscat]
      value_map$category %<>% na.locf0()
      value_map = value_map[-iscat]
      value_map %<>% filter(from != 'added')

      # drop row with non-numeric and convert to number.
      value_map %<>% filter(!grepl('[^0-9]', from)) %>% 
        # we'll ultimately need a character so jrepl can replace with character.
        # but convert to a number first so we have a consistent join.
        mutate(from = as.character(as.numeric(from))) 

      # clean title case.
      value_map$to = trimws(value_map$to)
      value_map$to = tools::toTitleCase(tolower(value_map$to))
      for(ival in c('To', 'And', 'Or', 'Of')) value_map$to = gsub(glue('\\b{ival}\\b'), tolower(ival), value_map$to)

      # value cleanup.
      lowercheck = tolower(value_map$to)
      value_map$to[lowercheck %in% c('niu', 'not in universe', 'not in universe (non-interview)')] <- 'Not In Universe'
      value_map$to[lowercheck %in% c('yes')] <- 'Yes'
      value_map$to[lowercheck %in% c('no')] <- 'No'
      value_map$to[lowercheck %in% c('none')] <- 'None'
      value_map$to = gsub('\\bHu\\b', 'HU', value_map$to)

      # save to list.
      dt[[i]]$value_map = value_map
      
      # the dictionary is no longer needed.
      dt[[i]]$dictionary = NULL
        
    }  

    save.cache(dt, states, counties, csas)
  
}
