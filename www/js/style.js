/**
 * Created by Guillermo on 30/10/16.
 */

var log_file_li_template = document.createElement('li');
log_file_li_template.setAttribute('data-role', 'log-trigger');
log_file_li_template.setAttribute('class', 'menu_item clickable');
log_file_li_template.setAttribute('data-url', '/LFS_F2/www/logs.html');


//<li  id="log_1" data-role="log-trigger" class="menu_item clickable" data-url="/LFS_F2/www/logs.html"><a>System</a></li>

function populateLogMenu(parent, logs, depth) {

    for (var iter in logs) {
        var log = logs[iter];
        console.log(log);
        if (log.type == 'folder' && log.childs.length > 0) {
            //create new parent ul
            var lili = document.createElement('li');
            var a = document.createElement('a');
            a.innerHTML = log.name + '<span class="fa fa-chevron-down"></span>';
            var new_ul = parent.cloneNode(false);
            new_ul.id = "log_menu_" + log.name;
            //call populate with the new ul
            populateLogMenu(new_ul, log.childs, depth + 1);
            lili.appendChild(a);
            lili.appendChild(new_ul);
            parent.appendChild(lili);
        } else if (log.type == 'file') {
            // clone li template
            var new_li = log_file_li_template.cloneNode(true);
            if (iter == 0 && depth > 0) {
                new_li.classList.add('sub_menu');
            }
            // mod id and url
            new_li.id = log.name;
            new_li.setAttribute('data-data', log.path);
            new_li.innerHTML = '<a>' + log.name + '</a>';
            // append new li to parent
            parent.appendChild(new_li);
        }
    }

}

var setContentHeight = function () {
    // reset height
    $RIGHT_COL.css('min-height', $(window).height());

    var bodyHeight = $BODY.outerHeight(),
        footerHeight = $BODY.hasClass('footer_fixed') ? -10 : $FOOTER.height(),
        leftColHeight = $LEFT_COL.eq(1).height() + $SIDEBAR_FOOTER.height(),
        contentHeight = bodyHeight < leftColHeight ? leftColHeight : bodyHeight;

    // normalize content
    contentHeight -= $NAV_MENU.height() + footerHeight;

    $RIGHT_COL.css('min-height', contentHeight);
};

function loadLogTypes() {

    $.ajax({
        type: "GET",
        //url: '/cgi-bin/getLogsAvailable.sh', //TODO activate this when script exists
        url: '/LFS_F2/www/menu_example.json',
        accepts:{
            html: 'application/json'
        },
        context: this,
        dataType: "json",

        // html retrieve call was *not* successful
        error: function() {
            $.notify("could not get available logs", "error");
        },

        // html retrieve call was successful
        //insert it on the main div. Since we just loaded the html we do not have to remove any content since its empty
        success: function(response_payload){
            console.log(response_payload);
            var parent_dude = document.getElementById('log_type_menu');
            //unpopulate parent
            while (parent_dude.firstChild) {
                parent_dude.removeChild(parent_dude.firstChild);
            }
            //populate parent
            populateLogMenu(parent_dude, response_payload, 0);
            //set onclick on new menu items
            $('.menu_item.clickable').click(setMainContent);

            $('#log_type_menu').find('a').on('click', function(ev) {
                var $li = $(this).parent();

                if ($li.is('.active')) {
                    $li.removeClass('active active-sm');
                    $('ul:first', $li).slideUp(function() {
                        setContentHeight();
                    });
                } else {
                    // prevent closing menu if we are on child menu
                    if (!$li.parent().is('.child_menu')) {
                        $SIDEBAR_MENU.find('li').removeClass('active active-sm');
                        $SIDEBAR_MENU.find('li ul').slideUp();
                    }

                    $li.addClass('active');

                    $('ul:first', $li).slideDown(function() {
                        setContentHeight();
                    });
                }
            });

        },

        failure: function () {
            $.notify("could not get available logs", "error");
        }
    });
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
            if ( trigger.getAttribute('data-role') == 'log-trigger' ) {
                window.path_of_selected_log = trigger.getAttribute('data-data');
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

$('.menu_item.clickable').click(setMainContent);

loadLogTypes();