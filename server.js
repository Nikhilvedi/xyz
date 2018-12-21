var express = require('express'),
  logger = require('morgan'),
  app = express(),
  template = require('jade').compileFile(__dirname + '/source/templates/homepage.jade')

import YouTubePlayer from 'youtube-player';

let player;
player = YouTubePlayer('video-player');
player.loadVideoById('dQw4w9WgXcQ');

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

app.get('/download', function(req, res) {
  var file = __dirname + '/Upload-folder/openme.txt';
  res.download(file); // Set disposition and send it.
});

app.get('/gitflow', function(req, res) {
   var file = __dirname + '/Upload-folder/gitflow.pdf';
    res.download(file);
});

app.get('/rickroll', function(req, res) {
    player.playVideo();
})

app.listen(process.env.PORT || 3000, function() {
  console.log('Listening on http://localhost:' + (process.env.PORT || 3000))
})
