sessdt = list()
getdata = function(x){

    ox = x
    x = tolower(x)

    if(x %ni% names(globaldt)){
        proginit(cc('Reading ', ox))
        proginc()
        file = glue('data/{x}')
        if(!file.exists(file)) stop(glue('File not found: [{file}].'))
        globaldt[[x]] <<- qread(file, nthreads = 2)
        progclose()
    }

    return(globaldt[[x]])
    
}
