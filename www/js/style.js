/**
 * Created by Guillermo on 30/10/16.
 */


function loadLogTypes(e) {

    var trigger = e.target.parentNode;

    $.ajax({
        type: "GET",
        //url: '/cgi-bin/getLogsAvailable.sh', //TODO activate this when script exists
        url: '/LFS_F2/www/menu_example.html',
        accepts:{
            html: 'text/html'
        },
        context: this,
        dataType: "html",

        // html retrieve call was *not* successful
        error: function() {
            $.notify("could not get available logs", "error");
        },

        // html retrieve call was successful
        //insert it on the main div. Since we just loaded the html we do not have to remove any content since its empty
        success: function(response_payload){
            document.getElementById('log_type_menu').innerHTML = response_payload;

            $('.menu_item.clickable').click(setMainContent);
        },

        failure: function () {
            $.notify("could not get available logs", "error");
        }
    });

    $('#'+trigger.id).toggleClass('non-toggled toggled');

}

function setMainContent(e){

    var trigger = e.target.parentNode;
    console.log(trigger);
    //make ajax request to obtain content of the dashboard (home screen)
    $.ajax({
        type: "GET",
        url: trigger.getAttribute('data-url'),
        accepts:{
            html: 'text/html'
        },
        context: this,
        dataType: "html",

        // html retrieve call was *not* successful
        error: function() {
            alert("could not get " + trigger.getAttribute('data-url'));
        },

        // html retrieve call was successful
        //insert it on the main div. Since we just loaded the html we do not have to remove any content since its empty
        success: function(response_payload){
            document.getElementById('main_wrapper').innerHTML = response_payload;
            $('.current-page').toggleClass('current-page');
            $('#'+trigger.id).toggleClass('current-page');
            if ( trigger.get('data-role') == 'log-trigger' ) {

            }
            $('.to_eval').each(function(){
                $.getScript( $(this).attr('src'), function( data, textStatus, jqxhr ) {
                    console.log( data ); // Data returned
                    console.log( textStatus ); // Success
                    console.log( jqxhr.status ); // 200
                    console.log( "Load was performed." );
                });
            });
            eval(document.getElementById('to_eval').innerHTML);
            $.notify("lets keep it going!", "error");
        },

        failure: function () {
            $.notify('could not load page async', 'error');
        }
    })

}

$('.log_menu.non-toggled').click(loadLogTypes);
$('.log_menu.toggled').click(function () {
    $('.log_menu.toggled').toggleClass('toggled non-toggled');
});
$('.menu_item.clickable').click(setMainContent);