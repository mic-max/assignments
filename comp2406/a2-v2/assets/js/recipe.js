/*
	Author: Michael Maxwell
	Student #: 101006277
*/

// will load the dropdown with the names of each recipe
$(() => {
	var $recipe = $('#recipe');
	var $duration = $('#duration');
	var $ingredients = $('#ingredients');
	var $steps = $('#steps');
	var $notes = $('#notes');
	var $check = $('#check');

	$.get('recipes/', (data) => {
		for(var i = 0; i < data.arr.length; i++) {
			var option = document.createElement('option');
			option.setAttribute('value', data.arr[i]);
			option.innerText = data.arr[i].replace(/\.json$/, '').replace(/_/g, ' ');
			$recipe.append(option);
		}
	}, 'json');

	$('#view').click(() => {
		$.get('recipes/' + $recipe.val(), (data) => {
			$duration.val(data.duration);
			$ingredients.val(data.ingredients.join('\n'));
			$steps.val(data.directions.join('\n'));
			$notes.val(data.notes);
			// note to self: resize textareas so there's no scroll bar?
		}, 'json');
	});
	
	$('#submit').click(() => {
		var recipeObj = {
			"name": $recipe.children('option').filter(':selected').text(),
			"duration": $duration.val(),
			"ingredients": $ingredients.val().split('\n'),
			"directions": $steps.val().split('\n'),
			"notes":  $notes.val()
		};

		console.log(recipeObj);
		$.post('recipes/', recipeObj);
	});
});

// will load data from current selected recipe into the text boxes
// note to self: could instead call this when the select option gets changed?


// will edit the file on the server to equal the data entered the inputs