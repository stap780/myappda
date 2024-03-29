function getActive(){
	console.log( document.querySelector('input[name="receiver-options"]:checked').value );
    //template_receiver
    var receiverField = $('#template_receiver'); //document.querySelector('#template_receiver');
    var value = document.querySelector('input[name="receiver-options"]:checked').value;
    if (value == "client"){
        receiverField.val(value);
        receiverField.addClass('d-none');
    }
    if (value == "manager"){
        receiverField.val('');
        receiverField.removeClass('d-none');
    }
}


$(document).ready(function() {
    document.querySelectorAll("input[name='receiver-options']").forEach( input => input.addEventListener('click', getActive) );
});