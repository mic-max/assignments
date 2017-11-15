$(() => {
	let userName = prompt('What\'s your name?') || 'User' + new Date().getMilliseconds()
	let typing = false
	let socket = io()

	socket.on('connect', () => {
		socket.emit('intro', userName)
	})
	
	// what to do when the user presses a key with the input element selected
	$('#input').keypress((ev) => {
		// console.log('TYPED:', ev.which)
		$this = $('#input');
		let value = $this.val()
		// add typing events here
		// only send this once.
		// SEND TYPING MESSAGE: if text input was empty and added text
		if(value === '' && !typing && ev.which !== 8) {
			// console.log('typing message')
			typing = true
			socket.emit('typing')
		}

		if(value.length === 1 && typing && ev.which === 8) {
			// console.log('deleted message')
			typing = false
			socket.emit('deleted')
		}

		// if they press enter, emit the message
		if(ev.which === 13) {
			// using $(this).val() wasn't working
			socket.emit('message', {
				username: userName,
				message: $this.val()
			})
			ev.preventDefault()
			$('#log').append((new Date()).toLocaleTimeString() + ', '+ userName + ': ' + $this.val() + '\n')
			typing = false
			$this.val('')
		}
	})
	
	// when sending a message, add it to the log and scroll to bottom
	socket.on('message', (data) => {
		deleteTypingIndicator(data.username)
		$('#log').append(timestamp() + ', ' + data.username + ': ' + data.message + '\n')
		$('#log')[0].scrollTop = $('#log')[0].scrollHeight
	})

	socket.on('connected', (data) => {
		$('#log').append(timestamp() + ', SERVER: ' + data + ' has joined the chatroom\n')
		$('#log')[0].scrollTop = $('#log')[0].scrollHeight
	})

	socket.on('typing', (data) => {
		enableTypingIndicator(data)
		console.log('TYPING:', data)
	})

	socket.on('deleted', (data) => {
		deleteTypingIndicator(data)
		console.log('DELETED', data)
	})

	// updates the userlist when needed
	socket.on('userList', (data) => {
		var $ul = $('#users').empty()
		for (var i = 0; i < data.length; i++) {
			var $li = $('<li>')
			$li.text(data[i])
			$li.dblclick(clickUser)
			$ul.append($li)
		}
	})

	// what to do when you receive a private message
	socket.on('privateMessage', (data) => {
		var msg = prompt(data.username + ': ' + data.message);
		if(msg) {
			socket.emit('privateMessage', {
				username: data.username,
				message: msg
			})
		}
	})

	// click event listener for userlist, used to block or pm users
	function clickUser(ev) {
		var $target = $(ev.target)
		if(ev.ctrlKey) {
			socket.emit('blockUser', {
				username: $target.text()
			})
			$target.toggleClass('blocked')
		} else {
			var msg = prompt('Send ' + $target.text() + ' a private message')
			if(msg) {
				socket.emit('privateMessage', {
					username: $target.text(),
					message: msg
				})
			}
		}
	}
})


function enableTypingIndicator(username) {
	let listItems = $('#users li')
	listItems.each(function(index) {
		if($(this).text() === username) {
			$(this).addClass('typing')
		}
	})
}

function deleteTypingIndicator(username) {
	let listItems = $('#users li')
	listItems.each(function() {
		if($(this).text() === username) {
			$(this).removeClass('typing')
		}
	})
}

function timestamp(){
	return new Date().toLocaleTimeString()
}