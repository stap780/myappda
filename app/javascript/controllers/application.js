import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }


// take from old 
function getActive(){
	console.log( document.querySelector('input[name="receiver-options"]:checked').value );
    var receiverField = document.querySelector('#template_receiver');
    var value = document.querySelector('input[name="receiver-options"]:checked').value;
    if (value == "client"){
        receiverField.value = value;
        receiverField.classList.add('d-none');
    }
    if (value == "manager"){
        receiverField.value = '';
        receiverField.classList.remove('d-none');
    }
}

document.addEventListener("turbo:load", () => {
    document.querySelectorAll("input[name='receiver-options']").forEach( input => input.addEventListener('click', getActive) );
});


function set_operation(elementValue){
    var searchChannel = elementValue;//element.value;
    console.log('searchChannel => ',searchChannel);
    document.querySelector('.event_event_actions_operation select').value = '';
    document.querySelector('.event_event_actions_operation option').classList.add('d-none');
    document.querySelectorAll('.event_event_actions_operation option').forEach(element => {
        element.classList.add('d-none');
        if (element.getAttribute('value2') == searchChannel) {
            element.classList.remove('d-none');
            element.classList.add('d-block');
        }
    });
}

function check_type(elementValue){
    var searchType = elementValue;//element.value; //element.value;
    console.log('searchType => ',searchType);
    if ( searchType == 'order' ) {
        document.querySelector('.event_custom_status').classList.remove('d-none');
        document.querySelector('.event_financial_status').classList.remove('d-none');
    } else {
        document.querySelector('.event_custom_status').classList.add('d-none');
        document.querySelector('.event_financial_status').classList.add('d-none');
    }
    if ( searchType == 'restock' ) {
        document.querySelector('.event_event_actions_timetable').classList.remove('d-none');
        document.querySelector('.event_event_actions_timetable_time').classList.remove('d-none');
        document.querySelector('.event_event_actions_timetable input').checked = true;
        document.querySelector('.event_event_actions_timetable_time select').selectedIndex = 1;
    } else {
        document.querySelector('.event_event_actions_timetable').classList.add('d-none');
        document.querySelector('.event_event_actions_timetable_time').classList.add('d-none');
        document.querySelector('.event_event_actions_timetable input').checked = false;
        document.querySelector('.event_event_actions_timetable_time select').selectedIndex = 0;
    }

}

document.addEventListener("turbo:load", () => {
    if (document.querySelector("#event_casetype")) {
        document.querySelector("#event_casetype").addEventListener("change", (event) => {
            check_type(event.target.value)
        });
    }
    if (document.querySelector(".event_event_actions_channel")) {
        document.querySelectorAll(".event_event_actions_channel select").forEach( element => {
            element.addEventListener('change', (event) => {
                set_operation(event.target.value)
            });
        });
    }
});



const events = [
    "turbo:fetch-request-error",
    "turbo:frame-missing",
    "turbo:frame-load",
    "turbo:frame-render",
    "turbo:before-frame-render",
    "turbo:load",
    "turbo:render",
    "turbo:before-stream-render",
    "turbo:before-render",
    "turbo:before-cache",
    "turbo:submit-end",
    "turbo:before-fetch-response",
    "turbo:before-fetch-request",
    "turbo:submit-start",
    "turbo:visit",
    "turbo:before-visit",
    "turbo:click"
  ]
  
  events.forEach(e => {
    addEventListener(e, () => {
      console.log(e);
    });
  });