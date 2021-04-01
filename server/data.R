sessdt = list()
getdata = function(x){

    ox = x
    x = tolower(x)

    if(x %ni% names(sessdt)){
        proginit(cc('Reading ', ox))
        proginc()
        file = glue('data/{x}')
        if(!file.exists(file)) stop(glue('File not found: [{file}].'))
        sessdt[[x]] <<- qread(file, nthreads = 2)
        progclose()
    }

    return(sessdt[[x]])
    
}
