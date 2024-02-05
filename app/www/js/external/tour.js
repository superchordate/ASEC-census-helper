var steps = [
    {
        element: "#Household-li p",
        content: "Choose a table to view the categories of data available.",
        next_timeout: 1000
    },
    {
        element: "#cfcat li:first-child() p",
        content: "Choose a category to see available fields.",
        next_timeout: 800
    },
    {
        element: "#table-fields li:nth-child(2) div p",
        content: "Click a field to add it to your selections.",
        next_timeout: 600
    },
    {
        element: '#selected_topic_show li:first-child p',
        content: 'Click a selection to un-select it.',
        next_timeout: 600
    },
    {
        element: '#cfcat li:nth-child(4) p',
        content: 'Try another category.',
        next_timeout: 600
    },
    {
        element: '#table-fields li:nth-child(1) div p',
        content: 'Choose another field',
        next_timeout: 600
    },
    {
        element: '#previewbutton p',
        content: 'View a summary-level preview of your data.',
        next_timeout: 600
    },
    {
        element: '#toprightinfo',
        content: 'The URL saves your selections.',
        next_timeout: 600
    },
    {
        element: '#toprightinfo',
        content: 'Detailed information is available on GitHub.',
        next_timeout: 600
    },
    {
        element: '#downloadbutton p',
        content: 'Download your data when you are ready.',
        next_timeout: 600
    },
    {
        content: 'Enjoy!'
    },
];
var step = 0;
var stoptour = false;

function nextstep(timeout, istep, first){
    
    if(istep == step && !stoptour){
        
        $('#tour').fadeOut(function(){ $('#tour').remove() });

        setTimeout(function(){
    
            if(first){
                if($("#selected_fields").val().length > 0){
                    stoptour = true;
                }
            }

            if(step < steps.length && !stoptour){
                //console.log('run');
                if(steps[step].element){

                    var rect = $(steps[step].element)[0].getBoundingClientRect();
            
                    $('body').append(`
                        <div 
                            id="tour" 
                            style="position: absolute; top: ` + (rect.top - 15) + 
                                `px; left: ` + (rect.left - 15) + 
                                `px; width: ` + (rect.width + 30) + 
                                `px; height: ` + (rect.height + 30) + 
                                `px; min-width: 200px; min-height: 120px; "
                            >
                            <div 
                                class="continue clickable" 
                                onclick = "$('` + steps[step].element + `')[0].click(); nextstep(` + steps[step].next_timeout + `, ` + (istep + 1) + `);"
                            >
                                <p class="content">` + steps[step].content + `</p>
                                <p class="clicktocontinue">Click to continue.</p>
                            </div>
                            <p class="cancel clickable" onclick="skiptutorial()">Skip tutorial</p>
                        </div>
                    `);    

                    step++;

                } else {
                    $('body').append(`
                        <div 
                            id = "tour" 
                            class = "clickable"
                            style = "position: absolute; min-width: 200px; min-height: 120px; top: calc(100vh / 2 - 60px); left: calc(100vw / 2 - 200px); "
                            onclick = "skiptutorial();"
                        >
                            <div class="continue">
                                <p class="content">` + steps[step].content + `</p>
                                <p class="clicktocontinue">Click to close tutorial.</p>
                            </div>
                        </div>
                    `);
                }
            }
        }, timeout) ;
    }
}

function skiptutorial(){
    stoptour = true;
    $('#tour').remove();
}
