// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require twitter/bootstrap
//= require dataTables/jquery.dataTables
//= require_tree .

function countChar(val) {
		var max = 160;
        var len = val.value.length;
        if (len == max) {
    		$('#charNum').text(' você atingiu o limite');
		} 
        else if (len > max) {
    		$('#charNum').text(' você excedeu o limite');
		} else {
		    var char = max - len;
		    $('#charNum').text(char);
		}
};
