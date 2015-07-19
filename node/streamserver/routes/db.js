var pg = require('pg');
var Pgb = require('pg-bluebird');
var pgb = new Pgb();

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

          var cnn;
          var p_id;

          if (pname != null && pname != '' && !pname.match(/[^\w\d\s]/)) {
              console.log(songs); // TODO: save the playlist!

              pgb.connect(conString)
              .then(function(connection) {
                cnn = connection;
                // Save a new playlist row
                cnn.client.query('INSERT into playlist(name) VALUES($1)', [pname]);
                return cnn.client.query('SELECT id from playlist WHERE name = $1', [pname]);
              })
              .then(function(result) {
                console.log("Saving playlist rows for new playlist id: ", result.rows[0].id);
                p_id = result.rows[0].id;
                var num = 1;
                songs.forEach(function(entry) {
                  cnn.client.query('INSERT into playlist_song(playlist_id, song_filepath, song_order) select $1, song_filepath, $3 from mp3s_tags where file_hash = $2', [ p_id, entry, num++ ] );
                });
              }).catch(function(error) {
                console.log("Error saving new playlist: ", error);
                res.render('basic', { title: 'Save Playlist - error', message: 'An error occurred trying to save your playlist. Please try again.'});
              });
              res.render('basic', { title: 'Save Playlist', message: 'Playlist ' + pname + ' saved.'});
          } else {
              if (pname == null) {
                console.log('pname was null');
              } else if (pname == '') {
                console.log('pname was empty');
              } else if (pname.match(/[^/w/d/s]/)) {
                console.log('pname contained a non-numeric/string/space character');
              } else {
                console.log('OOPS! i do not know why the playlist name "' + pname + '" was rejected!');
              }
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
