var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var ret = 'dunno';


// set up Jade and bodyParser
app.set('view engine', 'jade');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));


var basicroutes = require('./routes/basic');
var dbroutes = require('./routes/db');
app.use('/', basicroutes);
app.use('/', dbroutes);


app.use(express.static('public'));

var server = app.listen(3000, function() {

    var host = server.address().address;
    var port = server.address().port;

    console.log('Example app listening at http://%s:%s', host, port);

});
