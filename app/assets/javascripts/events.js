function set_operation(element){
    var searchChannel = element.value;
    //console.log(searchChannel);
    $('.event_event_actions_operation select').val('');
    $('.event_event_actions_operation option').hide();
    $('.event_event_actions_operation option').each(function() {
        if ( $(this).attr('value2') == searchChannel ) {
            $(this).show();
        }
    });
}
