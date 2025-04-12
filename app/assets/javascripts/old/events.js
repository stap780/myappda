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
    var searchType = element.value; //element.value;
    // console.log(searchType);
    if ( searchType == 'order' ) {
        $('.event_custom_status').removeClass('d-none');
        $('.event_financial_status').removeClass('d-none');
    } else {
        $('.event_custom_status').addClass('d-none');
        $('.event_financial_status').addClass('d-none');
    }
    if ( searchType == 'restock' ) {
        $('.event_event_actions_timetable').removeClass('d-none');
        $('.event_event_actions_timetable_time').removeClass('d-none');
        $('.event_event_actions_timetable input').prop( "checked", true );
        $('.event_event_actions_timetable_time select').prop('selectedIndex',1);
        $('.event_event_actions_pause_time').addClass('d-none');
    } else {
        $('.event_event_actions_timetable').addClass('d-none');
        $('.event_event_actions_timetable_time').addClass('d-none');
        $('.event_event_actions_timetable input').prop( "checked", false );
        $('.event_event_actions_timetable_time select').prop('selectedIndex',0);
    }

}

$(document).ready(function() {
    $('#event_casetype').change();
    // var selectedCasetype = $('#event_casetype').find(":selected").val(); //document.getElementById("event_casetype").value;
    // console.log(selectedCasetype)

    // check_type(selectedCasetype);

});
