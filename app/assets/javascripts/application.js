// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require jquery
//= require jquery_ujs
//= require popper
//= require bootstrap
//= require cocoon
//= require_tree .

$(document).ready(function() {

  if ($('#new_user').length > 0) {
    $('.navbar').css('display', 'none');
  }
  $(".alert").delay(4000).slideUp(200, function() {
    $(this).alert('close');
  });

  $('#q_created_at_datebegin').datepicker({
    format: 'yyyy-mm-dd',
    autoclose: true,
    language: "ru",
    todayHighlight: true
  });
  $('#q_created_at_dateend').datepicker({
    format: 'yyyy-mm-dd',
    autoclose: true,
    language: "ru",
    todayHighlight: true
  });
  $('#q_updated_at_datebegin').datepicker({
    format: 'yyyy-mm-dd',
    autoclose: true,
    language: "ru",
    todayHighlight: true
  });
  $('#q_updated_at_dateend').datepicker({
    format: 'yyyy-mm-dd',
    autoclose: true,
    language: "ru",
    todayHighlight: true
  });
  $('#q_valid_until_dateend').datepicker({
    format: 'yyyy-mm-dd',
    autoclose: true,
    language: "ru",
    todayHighlight: true
  });
  $('#payment_paymentdate').datepicker({
    format: 'yyyy-mm-dd',
    autoclose: true,
    language: "ru",
    todayHighlight: true
  });

  // setTimeout(function() {
  //     $(".alert").fadeTo(500, 0).slideUp(500, function(){
  //         $(this).remove();
  //     });
  // }, 2000);

  $('.check-integr').on('ajax:complete', function(data) {
    console.log(data);
  });
  document.body.addEventListener('ajax:success', function(event) {
    var detail = event.detail;
    console.log(detail);
    var data = detail[0],
      status = detail[1],
      xhr = detail[2];
  })

  $.each($('.preloaded-picture'), function(index, obj){
    var img = new Image();
    img.src = $(obj).attr('data-source');

    $(img).ready(function(){
      $(obj).attr('src', img.src);
    })
  })
//   $.each($('.preloaded-picture'), function(index, obj){
//     var url = $(obj).attr('data-api');
//     $.ajax({
//         type: "GET",
//         url: url,
//         dataType: 'json',
//         crossDomain: true,
//         success: function(resp) {
//           var data = JSON.parse(resp);
//           link = data[0]['compact_url']
//             $(obj).prop("src", link);
//         },
//         error: function() {
//     link = ''
// }
//     });
//   })
// SELECT ALL //
$('#selectAll').click(function() {
  if (this.checked) {
    $(':checkbox').each(function() {
      this.checked = true;
    });
    //$('#deleteAll').show();
  } else {
    $(':checkbox').each(function() {
      this.checked = false;
    });
    //$('#deleteAll').hide();
  }
});
// SELECT ALL //
// DELETE ALL //
$('#deleteAll').click(function() {
  var array = [];
  $('#items_table :checked').each(function() {
    array.push($(this).val());
  });
  // console.log(array);
  $.ajax({
    type: "POST",
    url: $(this).attr('href') + '.json',
    data: {
      ids: array
    },
    beforeSend: function() {
      return confirm("Вы уверенны?");
    },
    success: function(data, textStatus, jqXHR) {
      if (data.status === 'ok') {
        //alert(data.message);
        location.reload();
      }
    },
    error: function(jqXHR, textStatus, errorThrown) {
      console.log(jqXHR);
    }
  })
});
// DELETE ALL //
// CodeMirror.fromTextArea(document.getElementById("template-content"), {
//   lineWrapping: true,
//   // theme: "darcula",
//   // mode: "htmlmived",
//   //mode: "javascript"
//   mode: "markdown",
//   lineNumbers: true,
// });


var templateContent = document.getElementById("template-content");
// console.log(templateContent);
if (templateContent) {
  var editor = CodeMirror.fromTextArea(templateContent, {
    mode: "markdown",
    lineWrapping: true,
    lineNumbers: true,
  });
  editor.save()
}


const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))


});
