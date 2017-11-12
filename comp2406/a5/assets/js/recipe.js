/*
	Author: Michael Maxwell
	Student #: 101006277
*/

$(() => {
	$('#view').click(viewRecipe)
	$('#submit').click(sendRecipe)

	getRecipeList();
})

// will load the dropdown with the names of each recipe
function getRecipeList() {
	$.get('/recipes', (data) => {
		$recipe = $('#recipe')
		$recipe.empty()
		for(var i = 0; i < data.names.length; i++) {
			var $option = $('<option>')
			$option.val(data.names[i])
			$option.text(data.names[i].replace(/_/g, ' '))
			$recipe.append($option)
		}
	}, 'json')
}

// will load data from current selected recipe into the text boxes
// note to self: could instead call this when the select option gets changed?	
function viewRecipe() {
	$recipe = $('#recipe option:selected').val()
	if($recipe) {
		$.get('/recipe/' + $recipe, (data) => {
			$('#name').val(data.name.replace(/_/g, ' '))
			$('#duration').val(data.duration)
			$('#ingredients').val(data.ingredients.join('\n'))
			$('#steps').val(data.directions.join('\n'))
			$('#notes').val(data.notes)
			// note to self: resize textareas so there's no scroll bar?
		}, 'json')
	}
}

// will edit the file on the server to equal the data entered the inputs
function sendRecipe() {
	$.post('/recipe', {
		name: $('#name').val().replace(/ /g, '_'),
		duration: $('#duration').val(),
		ingredients: $('#ingredients').val().split('\n'),
		directions: $('#steps').val().split('\n'),
		notes: $('#notes').val()
	}, (data) => {
		$check = $('#check')
		$check.css('opacity', 1)
		setTimeout(() => {
			$check.css('opacity', 0)
		}, 2e3)
		getRecipeList()
	})
}