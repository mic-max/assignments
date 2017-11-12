/*
	Author: Michael Maxwell
	Student #: 101006277
*/

const PORT = 2406

var express = require('express')
var bodyParser = require('body-parser')
var MongoClient = require('mongodb').MongoClient

var db

var app = express()
MongoClient.connect('mongodb://localhost:27017/recipeDB', (err, database) => {
	if(err)
		throw err

	db = database
	app.listen(PORT, () => {
		console.log('Express @ localhost:', PORT)
	})
})

app.use((req, res, next) => {
	console.log(req.method, ':', req.url)
	next()
})

app.set('view engine', 'pug')
app.use(express.static('assets'))

app.get('/', (req, res) => {
	res.render('index')
})

// responds with an object with a single element called names which is an array of recipe names
app.get('/recipes', (req, res) => {
	names = []

	db.collection('recipes').find((err, docs) => {
		if(err)
			res.sendStatus(500)
		else {
			docs.each((err, doc) => {
				if(err)
					res.sendStatus(500)
				else if(doc)
					names.push(doc.name)
				else
					res.json({names: names.sort()})
			})
		}
	})
})

app.get('/recipe/:recipe', (req, res) => {
	db.collection('recipes').findOne({name: req.params.recipe}, (err, doc) => {
		if(err)
			res.sendStatus(500)
		else if(doc)
			res.json(doc)
		else
			res.sendStatus(404)
	})
})

app.use('/recipe', bodyParser.urlencoded({extended: true}))
app.post('/recipe', (req, res) => {
	if(req.body.name) {
		db.collection('recipes').update({name: req.body.name}, req.body, {upsert: true}, (err) => {
			res.sendStatus(err ? 500: 200)
		})
	} else
		res.sendStatus(400)
})