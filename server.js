var express = require('express'),
  logger = require('morgan'),
  app = express(),
  template = require('jade').compileFile(__dirname + '/source/templates/homepage.jade')

app.use(logger('dev'));
app.use(express.static(__dirname + '/static'));

app.get('/', function(req, res, next) {
  try {
    var html = template({
      title: 'Home'
    })
    res.send(html)
  } catch (e) {
    next(e)
  }
})

app.get('/blog',() => {

})

app.get('/download', function(req, res) {
  var file = __dirname + '/Upload-folder/openme.txt';
  res.download(file); // Set disposition and send it.
});

app.get('/rickroll', function(req, res) {
    res.send("No");
})

app.get('/generalkenobi', function(req, res) {
  res.send("Hello there");
})

app.get('/thisiswherethefunbegins', function(req, res) {
  res.send("https://static.wikia.nocookie.net/afbe0a28-af5a-4073-9579-1b56c0a33e22");
})

app.listen(process.env.PORT || 3000, function() {
  console.log('Listening on http://localhost:' + (process.env.PORT || 3000))
})
