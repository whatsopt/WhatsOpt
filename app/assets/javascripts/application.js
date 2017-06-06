//= require jquery
//= require tether
//= require jquery_ujs
//= require bootstrap
//= require d3
//= require_tree .

function add_fields(link, association, content) {
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + association, "g");
    console.log($(link).parent());
    $(link).parent().before(content.replace(regexp, new_id));
    $(link).parent().prev().children("a.remove-fields").click(function () {
	remove_fields(this);
    })
};

function remove_fields(link) {
    console.log($(link).prev("input"));
    $(link).prev("input").attr('value', "true");
    $(link).parent(".fields").hide();
}

$(document).ready(function() {
    $('a.remove-fields').click(function () {
	remove_fields(this);
    })
    $('a.add-fields').click(function () {
	add_fields(this,
		   $(this).attr('data-association'),
		   $(this).attr('data-content'));
    })
});
