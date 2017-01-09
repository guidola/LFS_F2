/**
 * Created by Guillermo on 30/10/16.
 */

var log_file_li_template = document.createElement('li');
log_file_li_template.setAttribute('data-role', 'log-trigger');
log_file_li_template.setAttribute('class', 'menu_item clickable');
log_file_li_template.setAttribute('data-url', 'logs.html');



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
        url: '/cgi-bin/getLogsAvailable.sh',
        accepts:{
            json: 'application/json'
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

var device_li_template = document.createElement('li');
device_li_template.setAttribute('class', 'menu_item');



function populateDeviceMenu(parent, devices) {

    for (var iter = 0; iter < devices.length; iter++) {
        var device = devices[iter];
        if (device.name == ""){continue}
        // clone li template
        var new_li = device_li_template.cloneNode(true);
        // mod id and url
        new_li.id = device.name.replace(/\s+/g, '');
        new_li.setAttribute('data-data', device.path);
        new_li.setAttribute('data-role', 'playlist-trigger');
        new_li.setAttribute('data-url', '/playlist.html');
        new_li.setAttribute('data-option', device.name);
        new_li.innerHTML = '<a>' + device.name + '<i class="fa float-right fa-play green list-trigger"></i></a>';

        // append new li to parent
        parent.appendChild(new_li);

    }

    $('.list-trigger').click(function (e) {

        e.stopPropagation();
        var path = e.target.parentNode.parentNode.getAttribute('data-data');

        // envia un load de la llista pertinent i canvia la pagina a la playlist
        window.path_of_selected_playlist = path;
        window.selected_device_id = e.target.parentNode.parentNode.id;
        window.selected_device_name = e.target.parentNode.parentNode.getAttribute('data-option');
        setMainContent({target: {parentNode: e.target.parentNode.parentNode}});
        console.log(e.target.parentNode.parentNode.id);
        $('li.bg-orange').toggleClass('bg-orange');
        $('#' + e.target.parentNode.parentNode.id).toggleClass('bg-orange');


    });

}


function loadDevices() {

    $.ajax({
        type: "POST",
        url: '/cgi-bin/show_devices.sh',
        accepts:{
            json: 'application/json'
        },
        context: this,
        dataType: "json",

        // html retrieve call was *not* successful
        error: function(payload) {
            console.log(payload);
            $.notify("could not get available devices", "error");
        },

        // html retrieve call was successful
        //insert it on the main div. Since we just loaded the html we do not have to remove any content since its empty
        success: function(response_payload){
            console.log(response_payload);
            var parent_dude = document.getElementById('devices_menu');
            //unpopulate parent
            while (parent_dude.firstChild) {
                parent_dude.removeChild(parent_dude.firstChild);
            }
            //populate parent
            populateDeviceMenu(parent_dude, response_payload.devices);
            $('#' + window.selected_device_id).toggleClass('bg-orange');

        },

        failure: function () {
            $.notify("could not get available devices", "error");
        }
    });
}

function setMainContent(e){

    var trigger = e.target.parentNode;
    window.clearInterval(window.interval_id);

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
        },

        failure: function () {
            $.notify('could not load page async', 'error');
        }
    })

}

function triggerBootAction(codi)  {

    $.ajax({
        type: "POST",
        url: '/cgi-bin/boot.sh',
        accepts:{
            json: 'text/json'
        },
        data: {
            codi: codi
        },
        context: this,
        dataType: "json",

        // html retrieve call was *not* successful
        error: function(e) {
            console.log(e);
            if(e.statusText == "OK"){
                $.notify("Action " + codi + " successfully performed. Wait in case of restart or power up again on power-off. Then reload.", 'success');
            } else {
                $.notify("could not trigger action " + codi, 'error');
            }
        },

        // html retrieve call was successful
        //insert it on the main div. Since we just loaded the html we do not have to remove any content since its empty
        success: function(response_payload){
            $.notify("Action " + codi + " successfully performed. Wait in case of restart or power up again on power-off. Then reload.", 'success');
        },

        failure: function (e) {
            if(e.statusText == "OK"){
                $.notify("Action " + codi + " successfully performed. Wait in case of restart or power up again on power-off. Then reload.", 'success');
            } else {
                $.notify("could not trigger action " + codi, 'error');
            }
            console.log(e);
        }
    })

}

function triggerPlayerAction(codi, song)  {

    var usb = window.path_of_selected_playlist === undefined ? null : window.path_of_selected_playlist;

    $.ajax({
        type: "POST",
        url: '/cgi-bin/music.sh',
        accepts:{
            json: 'text/json'
        },
        data: {
            action: codi,
            song: song,
            usb:  usb
        },
        context: this,
        dataType: "json",

        // html retrieve call was *not* successful
        error: function(r) {
            console.log(r);
            $.notify("could not trigger action " + codi, 'error');
        },

        // html retrieve call was successful
        //insert it on the main div. Since we just loaded the html we do not have to remove any content since its empty
        success: function(response){
            $.notify("Action " + codi + " successfully performed. Loaded new list status", 'success');

            if (codi == 0){
                $('#play').removeClass('glyphicon-pause');
                $('#play').removeClass('glyphicon-play');
                $('#play').addClass('glyphicon-pause');
            }
            //si es un play hem de canviar el botó per un pause
            //si es un pause hem de canviar el botó per un play
            if (codi == 1){$('#play').toggleClass('glyphicon-pause glyphicon-play')}
            //amb random urandom hem dactivar desactivar el boto
            if (codi == 4 || codi == 5){
                $('#random').toggleClass('green');
                var elem1 = document.getElementById('random').parentNode;
                elem1.setAttribute('data-data', elem1.getAttribute('data-data')==4?5:4 + "")
            }
            //amb repeat unrepeat hem dactivar desactivar el boto
            if (codi == 6 || codi == 7){
                $('#repeat').toggleClass('green');
                var elem2 = document.getElementById('repeat').parentNode;
                elem2.setAttribute('data-data', elem2.getAttribute('data-data')==6?7:6 + "")
            }

            //en qualsevol cas actualitzem la llist amb el nou estat
            console.log(response);
            if (response.rc) {
                var dades = response.payload;
                //load all logs
                var arrayin = [];

                for (var song_id in dades.list) {
                    var song_mas= parseInt(song_id)+1;
                    console.log(song_mas + " -- " + dades.current);
                    if (song_mas == dades.current) {
                        arrayin.push(["<i class='fa fa-music green center-y'>", dades.list[song_id]])
                    } else {
                        arrayin.push(["<i data-data=\"" + dades.list[song_id] + "\" class='fa fa-play green play-song center-y'>", dades.list[song_id]]);

                    }
                }
                var tablerino = $('#datatable_logs').DataTable({
                    retrieve: true,
                    order: []
                });
                tablerino.clear();
                tablerino.rows.add(arrayin).draw();
                document.getElementById('playlist_title').innerHTML = 'Playlist ' + window.selected_device_name;
                $('.play-song').click(function(e){triggerPlayerAction("0", e.target.getAttribute('data-data'))});

            } else {
                $.notify('Could not fetch logs!', 'error');
            }

        },

        failure: function (r) {
            console.log(r);
            $.notify("could not trigger action " + codi, 'error');
        }
    })

}


$('.player-action').click( function (e) {
    var node;
    if (e.target.tagName == 'SPAN') {
        node = e.target.parentNode.getAttribute('data-data')
    } else {
        node = e.target.getAttribute('data-data')
    }

    triggerPlayerAction(node, null);
});

$('.boot-action').click( function (e) {
    var node;
    if (e.target.tagName == 'SPAN') {
        node = e.target.parentNode.getAttribute('data-data')
    } else {
        node = e.target.getAttribute('data-data')
    }

    triggerBootAction(node);
});

$('#devices_wrapper').click(loadDevices);
loadLogTypes();
$('.menu_item.clickable').click(setMainContent);

$('#logout').click(function(){
    var cookies = $.cookie();
    for(var cookie in cookies) {
        $.removeCookie(cookie);
    }
    window.location = '/login.html';
});