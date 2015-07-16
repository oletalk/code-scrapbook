module.exports = (function() {
        'use strict';
        var router = require('express').Router();

        // basic sanity check - hello world
        router.get('/who', function (req, res) {
            // render sent json with Jade, using views/basic.jade
            res.render('basic', { title: 'Hey', message: 'Hello there!'});
        });

        // quick test that our createlist template works with the data structures
        // we expect back from our main PostgreSQL query
        router.get('/testlist', function (req, res) {
            res.render('createlist', {"list":[{"song_filepath":"1", "title":"2"}, {"song_filepath":"3", "title":"5"}]});
        });
   
        return router; 
    })();

