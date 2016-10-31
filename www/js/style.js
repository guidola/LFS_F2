/**
 * Created by Guillermo on 30/10/16.
 */


$('.menu_item').click(function setMainContent(e){

    var trigger = $(this)[0];
    //make ajax request to obtain content of the dashboard (home screen)
    $.ajax({
        type: "GET",
        url: '/LFS_F2/www' + trigger.getAttribute('data-url'),
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
            $('.current-page').attr('class', "");
            trigger.setAttribute('class', "current-page");
            $('.to_eval').each(function(){
                $.getScript( $(this).attr('src'), function( data, textStatus, jqxhr ) {
                    console.log( data ); // Data returned
                    console.log( textStatus ); // Success
                    console.log( jqxhr.status ); // 200
                    console.log( "Load was performed." );
                });
            });
            eval(document.getElementById('to_eval').innerHTML);
        },

        failure: function () {
            $('.current-page').attr('class', "");
        }
    })

});