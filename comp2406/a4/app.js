let http		= require('http')
  , express		= require('express')
  , socket		= require('socket.io')
  , socketRt	= require('./routes/socket')

let app 	= express()
  , server	= http.Server(app)
  , io		= socket(server)

// Settings
app.set('port', process.env.PORT || 3000)

// Middleware
app.use(express.static('public'))

// Attach routes
socketRt.attach(io, null)

server.listen(app.get('port'), function() {
	console.log('Chat server listening on port', app.get('port'))
})