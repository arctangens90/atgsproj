/*
 - func Load data on json file in DuaL List Box
  - Initialize duallistbox
  - reqeustParams: query parameters
  - selectElement: select element corresponding attribute
  - optionValue
  - optionText
  - selectedDataStr: selected data, the value is separated by
*/
 function initListBox(reqeustParams,selectElement,optionValue,optionText, selectedDataStr) {
   $.ajax({
 	 type:'POST',//Request method
 	 url: 'role',//address, is the request path of the json file
   beforeSend: function( xhr ) {//fix read json
     xhr.overrideMimeType( "text/plain; charset=x-user-defined" );
   },
 	 data: reqeustParams,//Request parameters
 	 async: true,//whether asynchronous
 	success: function (data) {
 	  var objs = $.parseJSON(data);
 	  var selector = $(selectElement)[0];
 	  $(objs).each(function () {
 		var o = document.createElement("option");
 		o.value = this[optionValue];
 		o.text = this[optionText];
 		if ("undefined" != typeof (selectedDataStr) && selectedDataStr != "") {
 		  var selectedDataArray = selectedDataStr.split(',');
 		  $.each(selectedDataArray, function (i, val) {
 			if (o.value == val) {
 			  o.selected = 'selected';
 			  return false;
 			}
 		  });
 		}
 		if(typeof(selector) != "undefined") {
 			selector.options.add(o);
 		}
 	  });
 	   //Render dualListbox
 	  $(selectElement).bootstrapDualListbox({
      nonSelectedListLabel: 'Available Roles',
      selectedListLabel: 'Accepted Roles',
      preserveSelectionOnMove: 'moved',
      moveAllLabel: 'Move all',
      removeAllLabel: 'Remove all'
 	  });
 	},
 	error: function (e) {
 	  alert(e.msg);
 	}
   });
 }
