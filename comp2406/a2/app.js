/*
	Author: Michael Maxwell
	Student #: 101006277
	Source: Used code from ./06f_asyncAjax/simpleServerAsync.js as a base
*/

const http = require('http');
const fs = require('fs');
const url = require('url');

const mime = require('mime-types');

const ROOT = './public_html';
const PORT = 2406;

var server = http.createServer(handleReq);
server.listen(PORT, () => {
	console.log('Server listening on port', PORT);
});


// handles different requests made on the server
// expected inputs are an http request and response
function handleReq(req, res) {
	var urlObj = url.parse(req.url);
	var filename = ROOT + urlObj.pathname;

	if(urlObj.pathname === '/')
		filename = ROOT + '/index.html';

	console.log(req.method + ' request for: ' + req.url);

	fs.stat(filename, (err, stats) => {
		if(err)
			respondErr(err);
		else if(stats.isDirectory()) {
			fs.readdir(filename, (err, files) => {
				if(err)
					respondErr(err);
				else if(urlObj.pathname === '/recipes/') {
					if(req.method === 'GET') {
						// respond with the recipe filenames in a json array
						var obj = {};
						obj.arr = files;
						filename = '.json'; // hack to make mimetype set properly
						respond(200, JSON.stringify(obj));
					} else if(req.method === 'POST') {
						// write file
						var post = '';
						req.setEncoding('utf-8');
						req.on('data', (chunk) => {		
							post += chunk;
						});
						req.on('end', () => {
							var recipeObj = JSON.parse(post);
							filename += '/' + recipeObj.name.replace(/ /g, '_') + '.json';
							fs.writeFile(filename, JSON.stringify(recipeObj) , (err) => {
								if(err)
									throw err;
								respond(200);
							});
						});
					} else
						respond(501, 'Method not implemented.');
				} else
					respond(200, files.join('<br>'));
				});
		} else {
			fs.readFile(filename, (err, data) => {
				if(err)
					respondErr(err);
				else
					respond(200, data);
			});
		}
	});

	// for if something goes wrong
	function respondErr(err) {
		console.log('Error');
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