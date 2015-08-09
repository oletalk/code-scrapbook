var Pgb = require('pg-bluebird');
var pgb = new Pgb();
var config = require('../config');

var conString = config.conString;

module.exports = (function() {
                'use strict';
  var router = require('express').Router();
  var playlistmap = new Map();

  router.get('/list/:id?', function (req, res) {
      var results = [];
      var cnn;
      var playlist_name = "";

      // we have a couple interdependent SQL statements 
      // so use pg-bluebird here
      pgb.connect(conString)
      .then(function(connection) {
        cnn = connection;
        
        if (typeof req.params.id !== 'undefined') {
          console.log('we got an id: ' + req.params.id);
          playlist_name = req.params.id;
          var sql = "select song_order as in_playlist, t.song_filepath, file_hash, case when title is null or title = '' then substring(t.song_filepath from '/([^/]*)$') else title end as title from mp3s_tags t join playlist_song ps on t.song_filepath = ps.song_filepath join playlist p on p.id = ps.playlist_id where file_hash is not null and (p.name = $1) order by song_order";
          return cnn.client.query(sql, [playlist_name]);
        }
        return {'rows':[]};
      })
      .then(function(result) {
        var numRows = result.rows.length;
        playlistmap.clear();
        for (var i = 0; i < numRows; i++) {
            playlistmap.set(result.rows[i].file_hash, result.rows[i].in_playlist);
            console.log("Playlist map - " + result.rows[i].file_hash + " -> " + result.rows[i].in_playlist);
        };
        console.log('previous result gave me ' + numRows + ' row(s).');
      var sql = "select 0 as in_playlist, song_filepath, file_hash, case when title is null or title = '' then substring(song_filepath from '/([^/]*)$') else title end as title, artist from mp3s_tags where file_hash is not null";
        return cnn.client.query(sql);
      })
      .then(function(result) {
        var numRows = result.rows.length;
        for (var i = 0; i < numRows; i++) {
          var datarow = result.rows[i];
          if (playlistmap.has(datarow.file_hash)) {
            console.log('Fetched playlist has entry for ' + datarow.file_hash);
            datarow.in_playlist = playlistmap.get(datarow.file_hash);
          }
          results.push(datarow);
        };
        cnn.client.end();
        console.log('query done!');
        res.render('createlist', {"list": results, "playlist": playlist_name});
      })
      .catch(function(error) {
        console.log("Error fetching database results: ", error);
      });

  });

      router.post('/save', function (req, res) {
          // TODO: pick up list_<songid> items instead of song checkboxes
          //       they contain the desired songs
          var songsstr = req.body.songids;
          var pname = req.body.playlistname;
          var songs = songsstr.split(",");
          console.log("We received a song list of " + songsstr + " which we split into '" + songs + "'.");

          var cnn;
          var p_id;
          var saved_ok = true;

          if (typeof songsstr === 'undefined' || songs.length == 0) {
            console.log("No songs requested!");
            res.render('basic', { title: 'Save Playlist', message: 'Empty playlist!  Nothing done.'});
          } else {

            if (pname != null && pname != '' && !pname.match(/[^\w\d\s]/)) {
                  // we've multiple sql statements here, some of which need previous results,
                  // so we'll use pg-bluebird
                pgb.connect(conString)
                .then(function(connection) {
                  cnn = connection;
                  // check if playlist with that name exists
                  return cnn.client.query('SELECT 1 FROM playlist WHERE name = $1', [pname]);
                })
                .then(function(result) {
                  if (result.rows.length == 0) {
                    return cnn.client.query('INSERT into playlist(name) VALUES($1)', [pname]);
                  } else {
                    return [];
                  }
                })
                .then(function(result) {
                  return cnn.client.query('SELECT id from playlist WHERE name = $1', [pname]);
                })
                .then(function(result) {
                  p_id = result.rows[0].id;
                  console.log("Saving playlist rows for new playlist id: ", p_id);
                  cnn.client.query('DELETE from playlist_song WHERE playlist_id = $1', [p_id]);
                  var num = 1;
                  songs.forEach(function(entry) {
                    var songdata = entry.split("_");
                    cnn.client.query('INSERT into playlist_song(playlist_id, song_filepath, song_order) select $1, song_filepath, $3 from mp3s_tags where file_hash = $2', [ p_id, songdata[1], num++ ] );
                  });
                  console.log("Returning success message.");
                  res.render('saved', { playlist: pname });
                }).catch(function(error) {
                  saved_ok = false;
                  console.log("Error saving new playlist: ", error);
                  // pass back useful error messages to the client
                  var errmsg = 'An error occurred trying to save your playlist. Please try again.';

                  console.log("Passing error message to client: " + errmsg);
                  res.render('basic', { title: 'Save Playlist - error', message: errmsg});
                });
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
          }
        });

      return router;

                })();
