output$trigger_download = downloadHandler(
    filename = function() {
        "census-extract.csv"
    },
    content = function(file) {
        idt = selected_data()
        write.csv(idt, file, row.names = FALSE)
    }
)
