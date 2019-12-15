// <script type="text/javascript">
//
//     function get_fio(elmnt,clr) {
//         var id = "<%=current_user.insints.first.password%>";
//         var sub = "<%=current_user.insints.first.subdomen%>";
//         var client = clr;
//         var uri = "http://"+sub+"/admin/clients/"+client+".json";
//         var basic = btoa("k-comment:" + id);
//         console.log(uri);
//         console.log(basic);
//         $.ajax({
//           type: 'GET',
//           username: "k-comment",
//           password: id,
//           xhrFields: {
//             withCredentials: true
//           },
//           crossDomain: true,
//           dataType: 'json',
//           beforeSend: function (xhr) {
//       xhr.setRequestHeader('Authorization', 'Basic ' + basic);
//   },
//           url: uri,
//           success: function(jsondata){
//           var searchClass = "fio-"+client ;
//           $( searchClass ).html( jsondata );
//           }
//         });
//     }
//
// </script>
