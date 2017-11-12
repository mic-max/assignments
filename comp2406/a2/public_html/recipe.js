/*
	Author: Michael Maxwell
	Student #: 101006277
*/

// will load the dropdown with the names of each recipe
window.onload = function() {
	var select = document.getElementById('recipe');
	var xhr = new XMLHttpRequest();

	xhr.open('GET', 'recipes/', true);
	xhr.onload = () => {
		var res = JSON.parse(xhr.responseText).arr;
		for(var i = 0; i < res.length; i++) {
			var option = document.createElement('option');
			option.setAttribute('value', res[i]);
			option.innerText = res[i].replace(/\.json$/, '').replace(/_/g, ' ');
			select.add(option);
		}
	};
	xhr.send();
};

// will load data from current selected recipe into the text boxes
// note to self: could instead call this when the select option gets changed?
function view() {
	var recipe = document.getElementById('recipe').value;
	var xhr = new XMLHttpRequest();

	xhr.open('GET', 'recipes/' + recipe, true);
	xhr.onload = () => {
		var recipeObj = JSON.parse(xhr.responseText);

		document.getElementById('duration').value = recipeObj.duration;
		document.getElementById('ingredients').value = recipeObj.ingredients.join('\n');
		document.getElementById('steps').value = recipeObj.directions.join('\n');
		document.getElementById('notes').value = recipeObj.notes;
		// note to self: resize textareas so there's no scroll bar?
	};
	xhr.send();
}

// will edit the file on the server to equal the data entered the inputs
function submit() {
	var check = document.getElementById('check');
	var recipe = document.getElementById('recipe');
	var recipeObj = {
		"name": recipe.options[recipe.selectedIndex].text,
		"duration": document.getElementById('duration').value,
		"ingredients": document.getElementById('ingredients').value.split('\n'),
		"directions": document.getElementById('steps').value.split('\n'),
		"notes":  document.getElementById('notes').value
	};

	var xhr = new XMLHttpRequest();
	xhr.open('POST', 'recipes/', true);
	xhr.setRequestHeader('Content-Type', 'application/json');
	xhr.onload = () => {
		if(xhr.status === 200) {
			check.style.opacity = '1';
			// after 3 seconds make it disapear
			setTimeout(() => {
				check.style.opacity = '0';
			}, 3000);
		}
	};
	xhr.send(JSON.stringify(recipeObj));
}