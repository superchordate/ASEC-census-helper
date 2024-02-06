value_swaps = c(
    field = 'Field ID',
    sample = 'Sample of Values',
    desc = 'Description',
    recordtype = 'Table'
)

clean_names = function(x){
    for(col in names(x)){
        if(col %in% names(value_swaps)){
            names(x)[names(x) == col] <- value_swaps[[col]]
        } else if(col %in% x){
            names(x)[names(x) == col] <- names(value_swaps)[value_swaps == col][1]       
        } else {
            names(x)[names(x) == col] <- tools::toTitleCase(tolower(col))
        }
    }
    return(x)
}

