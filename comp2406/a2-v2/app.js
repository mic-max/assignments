/*
	Author: Michael Maxwell
	Student #: 101006277
*/
const PORT = 2406;

var fs = require('fs');
var express = require('express');
var bodyParser = require('body-parser');

var app = express();
var jsonParser = bodyParser.json();

app.set('view engine', 'pug');

app.use(express.static('assets'));
app.use('/recipes', express.static('recipes'));

app.listen(PORT, () => {
	console.log('Express @ localhost:', PORT);
});

app.get('/', (req, res) => {
	res.render('index', {header: "Recipe Book"});
});

app.get('/recipes/', (req, res) => {
	fs.readdir('recipes/', (err, files) => {
		if(err)
			throw err;
		var obj = {};
		obj.arr = files;

		res.type('json');
		res.send(obj);
	});
});

app.post('/recipes/', jsonParser, (req, res) => {
	console.log(req.body);
	//res.send('welcome, ', req.body.name);
	/*
	var post = '';
	req.on('data', (chunk) => {		
		post += chunk;
	});
	console.log(post);
	req.on('end', () => {
		var recipeObj = JSON.parse(post);
		filename += '/' + recipeObj.name.replace(/ /g, '_') + '.json';
		fs.writeFile(filename, JSON.stringify(recipeObj) , (err) => {
			if(err)
				throw err;
			res.send();
		});
	});
	*/
});

app.get('*', (req, res) => {
	res.render('index', {header: "Error 404"});
});