var express = require('express');
var app = express();
var pg = require('pg');
var ret = 'dunno';
// postgresql regex to strip off path
// select song_filepath, file_hash, coalesce(title, substring(song_filepath from '%/#"%#"%' for '#')) as title from mp3s_tags 

var conString = "postgres://hitest:hipasswd@192.168.0.4/maindb";

app.set('view engine', 'jade');

app.get('/who', function (req, res) {
	// render sent json with Jade, using views/basic.jade
	res.render('basic', { title: 'Hey', message: 'Hello there!'});
});

app.get('/listtest', function (req, res) {
	res.render('createlist', {"list":[{"song_filepath":"1", "title":"2"}, {"song_filepath":"3", "title":"5"}]});
});
app.get('/list', function (req, res) {
	var results = [];
	var result = "";
	pg.connect(conString, function(err, client, done) {
			if (err) {
				return console.error('error fetching client from pool', err);
			}

			var sql = "select song_filepath, file_hash, case when title is null or title = '' then substring(song_filepath from '/([^/]*)$') else title end as title from mp3s_tags limit 100";
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
	
app.get('/stats', function (req, res) {

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

app.use(express.static('public'));

var server = app.listen(3000, function() {

    var host = server.address().address;
    var port = server.address().port;

    console.log('Example app listening at http://%s:%s', host, port);

});
