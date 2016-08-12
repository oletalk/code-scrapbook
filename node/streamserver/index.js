var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var config = require('./config.js');
var mongoose = require('mongoose');
var passport = require('passport');


// set up Jade and bodyParser
app.set('view engine', 'jade');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.disable('view cache'); // don't cache our views

mongoose.connect(config.mongoUrl);

var basicroutes = require('./routes/basic');
var dbroutes = require('./routes/db');
app.use('/', basicroutes);
app.use('/', dbroutes);

// ------------ passport stuff
passport.use(new LocalStrategy(
	function(username, password, done) {
		User.findOne({ username: username }, function (err, user) {
			if (err) { return done(err); }
			if (!user) {
				return done(null, false, { message: 'Incorrect username.'});
			}
			
			if (!user.validPassword(password)) {
				return done(null, false, { message: 'Incorrect password.'});
			}
			
			return done(null, user);
		});
	}));

app.post('/login',
	passport.authenticate('local'),
	function(req, res) {
		res.redirect('/users/' + req.user.username);
	}
);

// ------------ end passport stuff

app.use(express.static('public'));

var server = app.listen(3000, function() {

    var host = server.address().address;
    var port = server.address().port;

    console.log('app listening at http://%s:%s', host, port);

});
