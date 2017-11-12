/*
	Author: Michael Maxwell
	Student #: 101006277
*/

$(() => {
	var userName = prompt('What\'s your name?') || 'User' + new Date().getMilliseconds()
	var socket = io()

	socket.on('connect', () => {
		socket.emit('intro', userName)
	})
	
	// what to do when the user presses a key with the input element selected
	$('#input').keypress((ev) => {
		$this = $('#input');
		// if they press enter, emit the message
		if(ev.which === 13) {
			// using $(this).val() wasn't working
			socket.emit('message', $this.val())
			ev.preventDefault()
			$('#log').append((new Date()).toLocaleTimeString() + ', '+ userName + ': ' + $this.val() + '\n')
			$this.val('')
		}
	})
	
	// when sending a message, add it to the log and scroll to bottom
	socket.on('message', (data) => {
		$('#log').append(data + '\n')
		$('#log')[0].scrollTop = $('#log')[0].scrollHeight
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
})