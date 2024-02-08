#' Import Highcharts Libraries
#'
#' @param ... Code files to import, minimally defined. For example, to import https://code.highcharts.com/highcharts.js you'd send "highcharts". To import https://code.highcharts.com/modules/accessibility.js you'd send "modules/accessibility".
#'
#' @export
#'
#' @examples
#' \dontrun{
#' require(shiny)
#' ui = basicPage(
#'   hc_use(c(
#'     'highcharts',
#'     'modules/exporting',
#'     'modules/export-data',
#'     'modules/accessibility'
#'   )),
#'   uiOutput('testchart')
#' )
#' }
hc_use = function(hc_paths = c('highcharts', 'modules/accessibility')) lapply(
  hc_paths,
  function(module) htmltools::HTML(as.character(
    glue::glue('<script src="https://code.highcharts.com/{module}.js"></script>')
  ))
)

#' Built HTML for Highchart.
#'
#' Convers options and places the Highcharts Javascript inside a script tag. Put it inside a renderUI.
#'
#' @param id The HTML DOM id to use for the element and the output key to use. Must be HTML-compatible (no spaces).
#' @param options Highcharts options for the chart. Includes data, chart type, etc.
#' @param class "chart" in Highcharts.chart(... For Highmaps, it should be "mapChart".
#' @param loadmapfromurl If you are using a map, this is the URL of the topo.json file. Example: 'https://code.highcharts.com/mapdata/countries/us/us-ca-all.topo.json'
#' @param printjs Print completed JS to console for troubleshooting or pasting into jsFiddle.
#' @param pretty Use pretty formatting when converting options to JSON.
#'
#' @return HTML code for calling your chart.
#' @export
#'
#' @examples
#' \dontrun{
#'
#'require(shiny)
#'require(hcslim)
#'
#'shinyApp(
#'  
#'  ui = basicPage(
#'    usecode('highcharts'),    
#'    uiOutput('mychart')
#'  ),
#'
#'  server = function(input, output) {
#'
#'    output$mychart = renderUI({ 
#'      
#'      return(hc_html('mychart', list(
#'
#'        chart = list(type = 'line'),
#'        title = list(text = 'Some Numbers'),
#'        yAxis = list(
#'            title = list(
#'                text = '123456'
#'            )
#'        ),
#'        series = list(
#'          list(
#'            name = '123',
#'            data = c(1, 2, 3)
#'          ),
#'          list(
#'            name = '456',
#'            data = c(4, 5, 6)
#'          )
#'        )
#'        
#'      )))
#'      
#'    })
#'
#'})
#'
#' }
hc_html = function(
  id, 
  options, 
  class = c('chart', 'mapChart', 'stockChart', 'ganttChart'),
  loadmapfromurl = NULL,
  printjs = FALSE, 
  pretty = printjs
){
  
  # validate inputs.
  class = match.arg(class)
  hc_checkid(id)

  # if series data is a data frame, we need to convert it to a list.
  for(i in seq_along(options$series)) if(!is.vector(options$series[[i]]$data)){
    options$series[[i]]$data <- hc_dataframe_to_list(options$series[[i]]$data)
  }

  # if there is not title, add a blank one to prevent the default "Chart title"
  # if(is.null(options$title)) options$title = list(text = '')

  # initial conversion to JSON.
  json = jsonlite::toJSON(options, auto_unbox = TRUE, pretty = pretty, force = TRUE)
  
  # format markjs code as raw JS.
  json = gsub('"JS!([^!]+)!"', '\\1', json)

  # replace bad values with null.
  json = gsub('"(NA|-Inf|Inf)"', 'null', json)

  # Highcharts needs vectors, change single numbers to vectors.
  json = gsub('categories": ?([^[,} ]+)', 'categories": [\\1]', json)
  json = gsub('data": ?([^[,} ]+)', 'data": [\\1]', json)

  # compile final Highcharts JS call.
  # option to print completed JS to console for troubleshooting or pasting into jsFiddle.
  # add map download if necessary https://www.highcharts.com/docs/maps/map-collection
  if(!is.null(loadmapfromurl)){
    js = glue::glue('
      const topology = await fetch("{loadmapfromurl}").then(response => response.json()); 
      Highcharts.{class}("{id}", {json});
    ')
    html = glue::glue('<script>(async () => {{{js}}})();</script>')
  } else {
    js = glue::glue("Highcharts.{class}('{id}', {json});")
    html = glue::glue('<script>{js}</script>')
  }
  if(printjs) print(js)
  
  return(htmltools::HTML(as.character(html)))

}

#' Mark JS
#' 
#' Marks Javascript code so hchtml knows how to handle it.
#'
#' @param string 
#'
#' @return string with Javascript marked.
#' @export
#'
hc_markjs = function(string){
  return(as.character(glue::glue('JS!{string}!')))
}

#' Add grouped series. 
#' 
#' Seperating data into series is a very common operation. This function takes your grouped data and adds the series'.
#'
#' @param options Highcharts options for the chart. Includes data, chart type, etc.
#' @param data data.frame-like object containing the underlying data. It must already be grouped and summarized. 
#' @param groupcol Name of the column that will be used to split the data into series. These groups will show in the legend. 
#' @param xcol Name of the column to be used as the X value.
#' @param ycol Name of the column to be used as the Y value.
#'
#' @return options list with series' added. 
#' @export
#'
hc_addgroupedseries = function(options, data, groupcol, xcol, ycol){

    # validation.

      if('state' %in% names(data)) warning('
        [state] has a special usage in Highcharts. If you plan to use the column [state] you may experience issues.
        Suggest renaming to [state_abbr] or similar. 
        hcslim::addgroupedseries Warning W513.
      ')

      for(icol in c(groupcol, xcol, ycol)) if(!(icol %in% names(data))) stop(glue('
        Column [{icol}] was not found in the data. 
        hcslim::addgroupedseries Error 514.
      '))

    # select columns.
    data$x = data[[xcol]]
    data$y = data[[ycol]]
    data$group = data[[groupcol]]

    # this only works if using factors so we'll convert to factors.
    data$x = factor(data$x, levels = unique(data$x)) # set levels to preserve sorting.
    data$group = factor(data$group, levels = unique(data$group)) # set levels to preserve sorting.
    data %<>% droplevels() # unused levels will create chaos later.

    # we need a complete mapping so the series' line up.
    # fill missing segments.
    data %<>% right_join( # right join to keep sorting from data. 
      expand.grid(
          x = levels(data$x),
          group = levels(data$group)
      ),
      by = c('x', 'group')
    )

    # extract categories for x axis.
    categories = levels(data$x)

    # create each series.
    series = list()
    for(jdt in split(data, data$group)) series[[length(series) + 1]] <- list(
        name = as.character(jdt$group[1]),
        data = jdt %>% 
            mutate(x = as.numeric(x) - 1) %>% 
            select(-group) %>%
            list_parse()
    )

    options %<>% addoption('series', series)
    options %<>% addoption('xAxis', list(
        type = 'categorical',
        categories = categories
    ))

    return(options)

}

hc_checkid = function(id) if(grepl('[ ]', id)) stop(glue::glue('
  hcslim: Invalid id [{id}]. Must be HTML-compatible. See https://stackoverflow.com/a/79022/4089266.
'))

#.hcslimvars = new.env()
#assign('.loadedpaths', c(), envir=.hcslimvars)

#' Update Highcharts Options
#' 
#' Preserves current options while adding new ones. This isn't as exact as manually working the list, but may be convenient.
#'
#' @param options Highcharts options list.
#' @param option first-level (chart, xAxis, etc.) option to be modified.
#' @param ... Named second-level options (width, margin, etc.) to be set.
#'
#' @return List that can be passed to other functions.
#' @export
#'
#' @examples
hc_updateoption = function(options, option, ...){
  
  # add the first-level option if it doesn't exist yet.
  if(!(option %in% names(options))) options[[option]] = list()
  
  # get the new options.
  datalist = list(...)
  
  if(option=='colors'){
    options[[option]] = unlist(datalist)
  } else {
    for(i in names(datalist)) options[[option]][[i]] = datalist[[i]]
  }
  
  return(options)

}

# enabling the tooltip is not intuitive so we have this function to add it. 
hc_enabletooltips = function(options){
  if('plotOptions' %ni% names(options)) options$plotOptions = list()
  if('series' %ni% names(options$plotOptions)) ptions$plotOptions$series = list()
  options$plotOptions$series$enableMouseTracking = TRUE
  return(options)
}

hc_dataframe_to_list = function(x){
  if(nrow(x)==0) return(list())
  ilist = list()
  for(i in 1:nrow(x)){
    ilist[[i]] = list()
    for(j in 1:ncol(x)) ilist[[i]][[j]] = x[[j]][i]
  }
  return(ilist)
}
