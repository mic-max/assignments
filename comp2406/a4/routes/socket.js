let io = null
let db = null
let clients = []

// TODO replace all emit('message', {username: 'SERVER'}) with emit('serverMessage')

function disconnect(data) {
	console.log('DISCONNECT:', this.username)
	clients = clients.filter(function(ele) {
		return ele !== this
	})
	io.emit('message', {
		username: 'SERVER',
		message: this.username + ' disconnected.'
	})
	this.broadcast.emit('userList', getUserList())
}

function join(data) {
	console.log('CONNECT:', data)
	this.username = data
	this.blocked = []
	clients.push(this)
	this.broadcast.emit('connected', this.username)
	this.emit('message', {
		username: 'SERVER', 
		message: 'Welcome, ' + this.username
	})
	io.emit('userList', getUserList())
}

function message(data) {
	console.log('MESSAGE:', data)
	toUnblockedPeeps(this, 'message', {
		username: this.username,
		message: data.message
	})
}

function typing(data) {
	console.log('TYPING:', this.username)
	this.broadcast.emit('typing', this.username)
	// toUnblockedPeeps?
}

function deleted(data) {
	console.log('DELETED:', this.username)
	this.broadcast.emit('deleted', this.username)
	// toUnblockedPeeps?
}

function privateMessage(data) {
	for(let client of clients) {
		if(client.username === data.username && !client.blocked.includes(this.username)) {
			return client.emit('privateMessage', {
				username: this.username,
				message: data.message
			})
		}
	}
}

function blockUser(data) {
	let index = this.blocked.indexOf(data)
	// if that user is currently blocked, unblock them
	if(index >= 0) {
		this.blocked.splice(index, 1)
		this.emit('message', {
			username: 'SERVER',
			message: 'You unblocked ' + data
		})
	} else {
		this.blocked.push(data)
		this.emit('message', {
			username: 'SERVER',
			message: 'You blocked ' + data
		})
	}
}

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

exports.attach = function(IO, DB) {
	io = IO
	db = DB

	io.on('connection', function(socket) {
		socket.on('join', join)
		socket.on('message', message)
		socket.on('typing', typing)
		socket.on('deleted', deleted)

		socket.on('privateMessage', privateMessage)
		socket.on('blockUser', blockUser)

		socket.on('disconnect', disconnect)
	})
}