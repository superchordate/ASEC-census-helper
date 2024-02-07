
# we use an object-oriented approach to defining the inputs in the application.
# this lets us track inputs and also create our own consistent api. 
# by default, we set the id equal to the label for simplicity.

userinput = list(

    # properties/tracking.
    inputs_in_app = list(),
    input_types = c('select', 'text', 'number'),

    # useful functions. 
    inline = function(...) div(style='display: inline-block; vertical-align: top; ', ...),
    reset = function(){
        #TODO
    },
    input_type = function(id){
        input_type_forid = NULL
        for(i in userinput$input_types) if(id %in% userinput$inputs_in_app[[i]]){
            input_type_forid = i
            break
        }
        if(is.null(input_type_forid)) stop(glue('userinput: input not found for id [{id}]'))
        return(input_type_forid)
    },
    update_choices = function(id, choices){
        updateSelectizeInput(
            inputId = id, choices = choices, selected = intersect(isolate(input[[id]]), choices)
        )
    },

    # functions for including inputs in the UI.
    select = function(
        # if you want an input without a label, pass NULL label and your own id.
        label, id = label, 
        choices, 
        selected = NULL, multi = FALSE, width = NULL
    ){
        userinput$inputs_in_app$select = c(userinput$inputs_in_app$select, id)
        userinput$inline(selectizeInput(inputId = id, label = label, choices = choices, selected = selected, multiple = multi, width = width, options = list(plugins = list('remove_button'))))
    },
    text = function(        
        label, id = label, 
        selected = '', width = NULL
    ){
        userinput$inputs_in_app$text = c(userinput$inputs_in_app$text, id)
        userinput$inline(textInput(id, label = label, value = selected, width = width))
    },
    number = function(
        label, id = label, 
        min = NA, max = NA, step = NA, 
        selected = '', width = NULL
    ){
        userinput$inputs_in_app$number = c(userinput$inputs_in_app$number, id)
        userinput$inline(numericInput(id, label = label, step = step, min = min, max = max, value = selected, width = NULL))
    }

)
