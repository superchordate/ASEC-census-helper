if(!cache.ok(2)){

    # process dict2_raw
    rows = sapply(c('D', 'U', 'V'), function(x) which(grepl(cc('^', x, ' '), dict2_raw)))
    dict2_raw = sapply(dict2_raw, function(x){
        x = gsub('^(D|U|V) ', '', x)
        x = gsub('\\t', '', x)
        return(x)
    })
    names(dict2_raw) = NULL
    fields2 = NULL
    for(i in 1:length(rows$D)){
        
        thisd = rows$D[i]
        nextd = ifelse(i == length(rows$D), 99999, rows$D[i+1])
        vrows = rows$V[rows$V > thisd & rows$V < nextd]
        urows = rows$U[rows$U > thisd & rows$U < nextd]
        
        
        if(length(vrows) + length(urows) == 0){
            descrows = (thisd + 1):(nextd - 1)
        } else {
            descrows = (thisd + 1):(min(c(vrows, urows)) - 1)
        }
        if(length(descrows) > 1 && descrows[2] < descrows[1]) descrows = numeric()
        
        d = strsplit(dict2_raw[thisd], ' +')[[1]]
        if(d[1] == "") d = d[-1]
        
        idt = data.frame(
            name = d[1],
            begin = as.numeric(d[3]),
            end = as.numeric(d[3]) + as.numeric(d[2]) - 1 #d[2] is size.
        )
        
        if(is.na(as.numeric(d[3])) || is.na(as.numeric(d[2]))) browser()
        
        if(length(descrows) > 0) idt$desc = cc(trimws(dict2_raw[descrows]), sep = ' ')
        
        # get values.
        if(length(vrows) > 0){
            v = strsplit(dict2_raw[vrows], ' [.]')
            v = data.frame(
                key = sapply(v, function(x) x[1]),
                value = sapply(v, function(x) x[2])
            )
            rownames(v) = NULL
            idt$values = list(v)
            rm(v)
        }
        
        if(length(urows) > 0) idt$universe = cc(dict2_raw[urows])
        
        fields2 %<>% bind_rows(idt)
        
        rm(thisd, nextd, vrows, urows, d, idt)
    }
    fields2 %<>% relocate(desc)

    # split into rows and combine pages.
    dt = NULL
    pagenum = 0
    for(page in dict_raw){
        pagenum = pagenum + 1
        colnum = 0
        for(col in list(page[page$x < 317, ], page[page$x >= 317, ])){
            colnum = colnum + 1
            rows = unlist(lapply(split(col, col$y), function(x) cc(x$text, sep = " ")))
            dt = bind_rows(dt, data.frame(
                page = pagenum,
                col = colnum,
                row = 1:length(rows),
                data = rows,
                stringsAsFactors = FALSE
            ))
            rm(col)
    }}
    rm(pagenum, colnum, rows)

    # now order data in reading order. page > column > row
    dt %<>% arrange(page, col, row)
    dt$idx = 1:nrow(dt)
    rawdt = dt

    # drop rows we don't need (noise).
    dt %<>% filter(dt$data %ni% c(
        'Data Dictionary', 'Variable Length Position Range Variable', 'Range Length Position', 'Length Position Range',
        'ASEC 2020 Public Use Data Dictionary'
    ))
    dt %<>% filter(!grepl('^6[A-Z]-', dt$data))
    dt %<>% filter(!grepl('^[0-9]+ [0-9]+ [(].*[)]$', trimws(dt$data)))
    dt %<>% filter(!grepl('^[(].*[)] [0-9]+ [0-9]+$', trimws(dt$data)))

    # get record types, topics, and subtopics.
    dt$type = as.character(NA)
    dt$topic = as.character(NA)
    dt$subtopic = as.character(NA)

    # manual fixes.

        combinewithnext = function(x, idx_start){
            row = which(x$idx == idx_start)
            x$data[row] <- cc(trimws(x$data[row]), trimws(x$data[row+1]), sep = " ")
            x %<>% filter(idx != (idx_start + 1))
            return(x)
        }
        
        dt %<>% combinewithnext(2015)
        dt %<>% combinewithnext(2887)
        dt %<>% combinewithnext(3376)
        dt %<>% combinewithnext(6813)
        dt %<>% combinewithnext(7387)
        dt %<>% combinewithnext(7390)
        
        dt$data[which(dt$idx == 4893)] <- 'Universe: NA'
        
        rm(combinewithnext)

    # fix universe, topic on multiple lines.
    fixrows = grep('^(Universe:|Universe: .+ and|Topic:)$', trimws(dt$data))
    newrows = NULL
    for(i in fixrows) newrows %<>% bind_rows(data.frame(
        page = dt$page[i],
        col = dt$col[i],
        row = dt$row[i],
        data = cc(trimws(dt$data[i]), dt$data[i+1], sep = " "),
        stringsAsFactors = FALSE
    ))
    rm(i)
    
    dt %<>% filter(1:nrow(dt) %ni% c(fixrows, fixrows + 1))
    dt %<>% bind_rows(newrows) %>% arrange(page, col, row)
    rm(fixrows, newrows)

    recordtypes = grep('^Record Type: ', dt$data)
    recordtypes = recordtypes[!duplicated(dt$data[recordtypes])]
    dt$type[recordtypes] <- gsub('Record Type: ', '', dt$data[recordtypes])
    dt %<>% fill(type, .direction = 'down')
    dt$type[recordtypes] <- NA
    dt %<>% filter(!is.na(dt$type))
    dt %<>% filter(!grepl('^Record Type:', dt$data))
    rm(recordtypes)

    topics = grep('^Topic: ', dt$data)
    dt$topic[topics] <- gsub('Topic: ', '', dt$data[topics])
    dt %<>% fill(topic, .direction = 'down')
    dt$topic[topics] <- NA
    dt %<>% filter(!is.na(dt$topic))
    rm(topics)

    subtopics = grep('^SubTopic: ', dt$data)
    dt$subtopic[subtopics] <- gsub('Topic: ', '', dt$data[subtopics])
    dt %<>% fill(subtopic, .direction = 'down')
    dt$subtopic[subtopics] <- NA
    dt %<>% filter(!is.na(dt$subtopic))
    rm(subtopics)

    # now try to identify fields.
    rows_values = grep('^Values:', dt$data)
    rows_universe = grep('^Universe:', dt$data)
    rows_fields = c(1, (rows_universe + 1)[1:(length(rows_universe) - 1)]) # assumes first row is a field.
        
    # some columns have Values: and the first value mixed up (H_TELAVL)
    orderfix = function(x, irows_values){
        idx = x$idx[irows_values:(irows_values + 1)]
        val2 = x$data[which(x$idx == idx[1])]
        val1 = x$data[which(x$idx == idx[2])]
        x$data[which(x$idx == idx[1])] <- val1
        x$data[which(x$idx == idx[2])] <- val2
        return(x)
    }

    fields = NULL
    for(i in 1:length(rows_fields)){
        
        field = dt$data[rows_fields[i]]
        #if(field == "RESNSSA 1 888 (0:9)") browser()
        #if(grepl('PEDISREM', field)) browser()
        
        # some columns have 0 value before "Values:" tag.
        # this will fix the order.
        if(
            dt$data[rows_values[i]] == 'Values:' &&
            grepl('[0-9]', dt$data[rows_values[i] - 1])
        ){
            #browser()
            
            #dt$data[rows_values[i]-1]
            #dt$data[rows_values[i]]
            #dt$data[rows_values[i]+1]
            
            #dt$data[rows_fields[i]]
            #dt$data[rows_fields[i] + 1]
            
            dt = orderfix(dt, rows_values[i]-1)
        }
        
        desc = cc(dt$data[(rows_fields[i] + 1):(rows_values[i]-1)])
        desc = gsub('Values:$', '', desc) # sometimes the above results in appending "Values:"
        desc = gsub('[.]{2,}', '_', desc) # will break the next line.
        desc = strsplit(desc, '[.]')[[1]]
        info = if(length(desc) > 1){
            cc(desc[-1], sep = ".")
        } else {
            ''
        }
        desc = desc[1]
        if(length(desc) != 1) browser()
        
        if(desc == '') stop('Bad desc. Error 1222.')
        
        idt = data.frame(
            field = field,
            desc = desc,
            recordtype = dt$type[rows_fields[i]],
            topic = dt$topic[rows_fields[i]],
            subtopic = dt$subtopic[rows_fields[i]],
            values = trimws(gsub('Values:', '', cc(dt$data[(rows_values[i]):(rows_universe[i]-1)], sep = ' '))),
            universe = trimws(gsub('Universe:', '', dt$data[rows_universe[i]])),
            page = dt$page[rows_fields[i]],
            col = dt$col[rows_fields[i]],
            row = dt$row[rows_fields[i]],
            idx = dt$idx[rows_fields[i]],
            stringsAsFactors = FALSE
        )
        #if(grepl('H_TELAVL', dt$data[rows_fields[i]])) print(idt)
        
        fields %<>% bind_rows(idt)
        rm(i, idt)
    
    }
    rm(rows_values, rows_universe, rows_fields)

    fields$fixfield = toupper(fields$field)
    fields$fixfield = str_extract(fields$fixfield, '[A-Z][A-Z0-9_]{2,}')
    
    # validate fields match to data.
        
        allcols = setdiff(
            unique(c(names(family_raw), names(household_raw), names(person_raw))),
            'YYYYMM'
        )
        missingcols = setdiff(allcols, fields$fixfield)
        if(length(missingcols) > 0) warning(glue('Fields not found including: [{cc(head(missingcols), sep =", ")}]'))
        rm(missingcols)
        
        newcols = setdiff(fields$fixfield, allcols)
        if(length(newcols) > 0) warning(glue('Fields not in data including: [{cc(head(newcols), sep =", ")}]'))
        rm(newcols)
        
        rm(allcols)
    
    # set final field names.
    fields %<>% mutate(field = fixfield) %>% select(-fixfield)
    rm(dict_raw)

}
