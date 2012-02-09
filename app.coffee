onHeroku = process.env.PORT

if onHeroku
  dbString = "mongodb://heroku:ukoreh@staff.mongohq.com:10041/app2738679"
  port     = process.env.PORT
else
  dbString = "localhost:27017/grocery-items"
  port     = 3000

express   = require('express')
stylus    = require('stylus')
mongo     = require('mongoskin')
coffee    = require('coffee-script')
db        = mongo.db(dbString)
itemsColl = db.collection('items')
usersColl = db.collection('users')
routes    = require('./routes')
app       = module.exports = express.createServer()
io        = require('socket.io').listen(app)
coffeeDir = __dirname + '/coffee'
publicDir = __dirname + '/public'
cssDir    = publicDir + '/stylesheets'


# Configuration

app.configure ->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)
  app.use(express.compiler({src: coffeeDir, dest: publicDir, enable: ['coffeescript']}))
  app.use(stylus.middleware({src: publicDir, compress: true}))
  app.use express.static(publicDir)

if onHeroku
  io.configure ->
    io.set("transports", ["xhr-polling"])
    io.set("polling duration", 10)

app.configure 'development', ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', ->
  app.use(express.errorHandler())


# Routes
app.get '/', (req, res) ->
  res.render('index')

app.get '/list', (req, res) ->
  itemsColl.find({purchased: false}).toArray (error, items) ->
    data = JSON.stringify(items)
    res.render('list', {items: data})



# Database

insertEntry = (data, callback) ->
  itemsColl.insert data, ->
    callback()

editEntry = (data, callback) ->
  itemsColl.updateById data._id, {$set: {name: data.name}}, ->
    callback()

deleteEntry = (data, callback) ->
  itemsColl.removeById data._id, ->
    callback()



# Sockets

io.sockets.on 'connection', (socket) ->
  socket.on 'new item posted', (data) ->
    insertEntry data, ->
      io.sockets.emit('new item saved', data)

  socket.on 'item edited', (data) ->
    editEntry data, ->
     io.sockets.emit('item was edited', data)

  socket.on 'item deleted', (data) ->
    deleteEntry data, ->
      io.sockets.emit('item was deleted', data)

app.listen(port)
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env)
