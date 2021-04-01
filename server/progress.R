# https://shiny.rstudio.com/articles/progress.html
progress = NULL

proginit = function(message = '', value = 0){
    if(is.null(progress)){
        progress = shiny::Progress$new()
        progress$set(message, value = value)
        progress <<- progress
    }
}

proginc = function(message = '', pct = 0.15) if(!is.null(progress)) {
    progress$inc(pct, detail = message)
}

progclose = function()if(!is.null(progress)){
    progress$close()
    progress <<- NULL
}