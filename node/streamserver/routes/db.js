var pg = require('pg');
var conString = "postgres://hitest:hipasswd@192.168.0.4/maindb";

module.exports = (function() {
                'use strict';
  var router = require('express').Router();


  router.get('/list', function (req, res) {
      var results = [];
      var result = "";
      pg.connect(conString, function(err, client, done) {
              if (err) {
                  return console.error('error fetching client from pool', err);
              }

              var sql = "select song_filepath, file_hash, case when title is null or title = '' then substring(song_filepath from '/([^/]*)$') else title end as title from mp3s_tags where file_hash is not null limit 200";
              var query = client.query(sql);
              query.on('row', function(row) {
                      results.push(row);
                      } );
              query.on('end', function() {
                      client.end();
                      res.render('createlist', {"list": results});
              });
          });
      });

      router.post('/save', function (req, res) {
          var songs = req.body.songs;
          var pname = req.body.playlistname;
          if (pname != null && pname != '' && !pname.match('[^\w\d\s]')) {
              console.log(songs); // TODO: save the playlist!
              res.render('basic', { title: 'Save Playlist', message: 'Playlist ' + pname + ' saved.'});
          } else {
              res.render('basic', { title: 'Save Playlist', message: 'Invalid playlist name - must not be empty, and it can have only letters, numbers and spaces' } );
          }
          });

      router.get('/stats', function (req, res) {

          var results = [];
          pg.connect(conString, function(err, client, done) {
                  if (err) {
                      return console.error('error fetching client from pool', err);
                  }
                  var sql = 'SELECT category, count(*) FROM mp3s_stats GROUP BY 1;';
                  var query = client.query(sql);
                  query.on('row', function(row) {
                          results.push(row);
                      } );
                  query.on('end', function() {
                          client.end();
                          return res.json(results);
                      } );
              });
          //res.send(ret); // hmmm. callback for above query gets executed later than this line,
                         // so ret will be 'dunno', not 4
      });
      return router;

                })();
