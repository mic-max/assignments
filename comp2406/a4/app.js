const http = require('http').createServer(handler)
const fs = require('fs')
const url = require('url')

const io = require('socket.io')(http)

const PORT = 9001
const ROOT = './public'
let clients = []

http.listen(PORT, () => {
	console.log('Chat server listening on port', PORT)
})

function handler(req, res) {
	const urlObj = url.parse(req.url, true)
	let filename = ROOT + urlObj.pathname

	console.log(req.method, 'request for:', req.url)

	fs.stat(filename, (err, stats) => {
		if(err) {
			res.writeHead(500)
			res.end('Error loading ' + urlObj.pathname)
		} else {
			if(stats.isDirectory())
				filename = ROOT + '/index.html'
			fs.readFile(filename, (err, data) => {
				if(err) {
					res.writeHead(500)
					res.end('Error loading ' + urlObj.pathname)
				} else {
					res.writeHead(200)
					res.end(data)
				}
			})
		}
	})
}

io.on('connection', (socket) => {
	socket.on('intro', (data) => {
		console.log('CONNECT:', data)
		socket.username = data
		socket.blocked = []
		clients.push(socket)
		socket.broadcast.emit('connected', socket.username)
		socket.emit('message', {
			username: 'SERVER', 
			message: 'Welcome, ' + socket.username
		})
		io.emit('userList', getUserList())
	})

	// when a user types a message in the chat
	socket.on('message', (data) => {
		console.log('MESSAGE:', data)
		// set typing to false for this socket
		// socket.typing = false
		// only emit to people that haven't blocked the sender
		for(let client of clients) {
			if(!client.blocked.includes(socket.username) && client != socket)
				client.emit('message', {
					username: data.username, // socket.username or data.username
					message: data.message
				})
		}
		// socket.broadcast.emit('message', timestamp() + ', ' + socket.username + ': ' + data)
	})

	socket.on('typing', () => {
		// socket.typing
		console.log('TYPING:', socket.username)
		// TODO only broadcast to people who haven't blocked this user
		socket.broadcast.emit('typing', socket.username)
	})

	socket.on('deleted', () => {
		console.log('DELETED:', socket.username)
		socket.broadcast.emit('deleted', socket.username)
	})

	// when a user disconnects
	socket.on('disconnect', () => {
		console.log('DISCONNECT:', socket.username)
		clients = clients.filter((ele) => {
			return ele !== socket
		})
		io.emit('message', {
			username: 'SERVER',
			message: socket.username + ' disconnected.'
		})
		socket.broadcast.emit('userList', getUserList())
	})

	// when a user sends a non-empty private message
	socket.on('privateMessage', (data) => {
		for(var i = 0; i < clients.length; i++) {
			var client = clients[i]
			if(client.username === data.username && !client.blocked.includes(socket.username)) {
				return clients[i].emit('privateMessage', {
					username: socket.username,
					message: data.message
				})
			}
		}
	})

	// when a user blocks another user
	socket.on('blockUser', (data) => {
		var index = socket.blocked.indexOf(data.username)
		if(socket.blocked.includes(data.username)) {
			socket.blocked.splice(index, 1)
			socket.emit('message', 'Unblocked ' + data.username)
		} else {
			socket.blocked.push(data.username)
			socket.emit('message', 'Blocked ' + data.username)
		}
	})
})

function timestamp(){
	return new Date().toLocaleTimeString()
}

function getUserList() {
	var ret = []
	for(var i = 0; i < clients.length; i++)
		ret.push(clients[i].username)
	return ret
}