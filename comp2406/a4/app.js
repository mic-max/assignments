const PORT = 9001
const express = require('express')

let app = express()
let server = require('http').Server(app)
let io = require('socket.io')(server)

let clients = []
// TODO replace all emit('message', {username: 'SERVER'}) with emit('serverMessage')

app.use(express.static('public'))

server.listen(PORT, () => {
	console.log('Chat server listening on port', PORT)
})

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

	socket.on('message', (data) => {
		console.log('MESSAGE:', data)
		toUnblockedPeeps(socket, 'message', {
			username: data.username, // socket.username or data.username
			message: data.message
		})
	})

	socket.on('typing', () => {
		console.log('TYPING:', socket.username)
		socket.broadcast.emit('typing', socket.username)
		// toUnblockedPeeps?
	})

	socket.on('deleted', () => {
		console.log('DELETED:', socket.username)
		socket.broadcast.emit('deleted', socket.username)
		// toUnblockedPeeps?
	})

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

	socket.on('privateMessage', (data) => {
		for(let client of clients) {
			if(client.username === data.username && !client.blocked.includes(socket.username)) {
				return client.emit('privateMessage', {
					username: socket.username,
					message: data.message
				})
			}
		}
	})

	socket.on('blockUser', (data) => {
		let index = socket.blocked.indexOf(data)
		// if that user is currently blocked, unblock them
		if(index >= 0) {
			socket.blocked.splice(index, 1)
			socket.emit('message', {
				username: 'SERVER',
				message: 'You unblocked ' + data
			})
		} else {
			socket.blocked.push(data)
			socket.emit('message', {
				username: 'SERVER',
				message: 'You blocked ' + data
			})
		}
	})
})

function toUnblockedPeeps(sock, type, data) {
	for(let client of clients) {
		if(!client.blocked.includes(sock.username) && client != sock)
			client.emit(type, data)
	}
}

function getUserList() {
	var ret = []
	for(let client of clients)
		ret.push(client.username)
	return ret
}

function timestamp(){
	return new Date().toLocaleTimeString()
}