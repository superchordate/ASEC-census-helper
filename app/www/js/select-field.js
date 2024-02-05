function select_field(id, label){
    if(id) $('#' + id).fadeOut(250, function(){ 
        $('#' + id).remove();
        console.log({'id': id, 'label': label });
        const newhtml = `
            <li class="lifade" style="display: list-item;" id="` + id + `">
                <div class="clickable small" style="position: relative"">
                <div style="position: absolute; top: 0px; left: 0px; font-size: 10pt; padding: 5px; padding-top: 0;">
                    <i class="fas fa-window-close"></i>
                </div>
                    <p>` + label + `</p>
                </div>
            </li>
        `
        console.log(newhtml);
        $('#selected_fields_show ul').append(newhtml);
        $('#' + id).on('click', function(){ unselect_field(id, label) });
        $('#selected_fields_show > div').removeClass('hidden');
    })
    Shiny.onInputChange('add_field', label);
}

function unselect_field(id, label){
    if(id) $('#' + id).fadeOut(250, function(){ 
        $('#' + id).remove(); 
        $('#table-fields ul').append(`
            <li class="lifade" style="display: list-item;" id="` + id + `">
                <div class="clickable">
                    <p>` + label + `</p>
                </div>
            </li>
        `);
        $('#' + id).on('click', function(){ select_field(id, label) });
    });
    Shiny.onInputChange('remove_field', label);
}
