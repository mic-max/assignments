/*
	Author: Michael Maxwell
	Student #: 101006277
	Source: Used code from ./06f_asyncAjax/simpleServerAsync.js as a base
			Used makeBoard.js provided in assignment
*/
const ROOT = './assets';
const PORT = 2406;

const http = require('http');
const fs = require('fs');
const url = require('url');

const mime = require('mime-types');
const runkaB = require(ROOT + '/js/makeBoard');

var clients = [];

var server = http.createServer(handleReq);
server.listen(PORT, () => {
	console.log('Server listening on port', PORT);
});

// handles different requests made on the server
// expected inputs are an http request and response
function handleReq(req, res) {
	var urlObj = url.parse(req.url, true);
	var filename = ROOT + urlObj.pathname;

	console.log(req.method + ' request for: ' + req.url);

	if(urlObj.pathname === '/memory/intro') {
		var user = urlObj.query.user;
		if(clients[user]) {
			var diff = clients[user].diff + 2;
			clients[user] = {
				diff: diff,
				board: runkaB.makeBoard(diff)
			};
		} else {
			clients[user] = {
				diff: 4,
				board: runkaB.makeBoard(4)
			}
		}
		respond(200);
	} else if(urlObj.pathname === '/memory/card') {
		var row = parseInt(urlObj.query.row);
		var col = parseInt(urlObj.query.col);
		var user = urlObj.query.user;

		var obj = {
			value: clients[user].board[row][col]
		};
		filename = '.json'; // hack to make mimetype set properly
		respond(200, JSON.stringify(obj));
	} else {
		fs.stat(filename, (err, stats) => {
			if(err)
				respondErr(err);
			else {
				if(stats.isDirectory())
					filename = ROOT + '/index.html';
				fs.readFile(filename, (err, data) => {
					if(err)
						respondErr(err);
					else
						respond(200, data);
				});
			}
		});
	}

	// for if something goes wrong
	function respondErr(err) {
		console.log('Error: ', err);
		if(err.code === 'ENOENT')
			serve404();
		else
			respond(500, err.message);
	}

	// serves the 404 page
	function serve404() {
		fs.readFile(ROOT + '/404.html', 'utf-8', (err, data) => {
			if(err)
				respond(500, err.message);
			else
				respond(404, data);
		});
	}

	// repsponds to the client with their data
	function respond(code, data) {
		res.writeHead(code, {'content-type': mime.lookup(filename) || 'text/html'});
		res.end(data);
	}
};