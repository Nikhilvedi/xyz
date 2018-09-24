var express = require('express'),
  logger = require('morgan'),
  app = express(),
  template = require('jade').compileFile(__dirname + '/source/templates/homepage.jade')

app.use(logger('dev'))
app.use(express.static(__dirname + '/static'))

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

app.get('/download', function(req, res) {
  var file = __dirname + '/Upload-folder/openme.txt';
  res.download(file); // Set disposition and send it.
});

app.get('/gitflow', function(req, res) {
   var file = __dirname + '/Upload-folder/gitflow.pdf';
  new PdfReader().parseFileItems(file, function(err, item) {
    if (err)
      callback(err);
    else if (!item)
      callback();
    else if (item.text)
      console.log(item.text);
  });
});

app.listen(process.env.PORT || 3000, function() {
  console.log('Listening on http://localhost:' + (process.env.PORT || 3000))
})