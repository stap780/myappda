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

function check_type(element){
    var searchType = element.value;
    //console.log(searchType);
    if ( searchType === 'order' ) {
        $('.event_custom_status').removeClass('d-none');
        $('.event_financial_status').removeClass('d-none');
    } else {
        $('.event_custom_status').addClass('d-none');
        $('.event_financial_status').addClass('d-none');
    }   
}
