var express = require('express'),
  logger = require('morgan'),
  app = express(),
  template = require('pug').compileFile(__dirname + '/source/templates/default.pug'),
  starwars = require('pug').compileFile(__dirname + '/source/templates/starwars.pug'),
  pod = require('pug').compileFile(__dirname + '/source/templates/pod.pug'),
  cv = require('pug').compileFile(__dirname + '/source/templates/cv.pug')

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

app.get('/hellothere', function(req, res) {
  res.send("General Kenobi");
})

app.get('/cv', function(req, res, next) {
  try {
    var html = cv({
      title: 'CV'
    })
    res.send(html)
  } catch (e) {
    next(e)
  }
})

app.get('/cv/download', function(req, res) {
  var file = __dirname + '/static/resume/cv.pdf';
  res.download(file);
})

app.get('/thisiswherethefunbegins', function(req, res, next) {
  try {
    var html = starwars({
      title: 'Home'
    })
    res.send(html)
  } catch (e) {
    next(e)
  }
})

app.get('/pod', function(req, res, next) {
  try {
    var html = pod({
      title: 'Oopsie'
    })
    res.send(html)
  } catch (e) {
    next(e)
  }
})

app.listen(process.env.PORT || 3000, function() {
  console.log('Listening on http://localhost:' + (process.env.PORT || 3000))
})
