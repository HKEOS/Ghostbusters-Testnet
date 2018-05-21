const mongoose = require('mongoose');
const Eos = require('eosjs');

mongoose.connect('mongodb://localhost/test');
const db = mongoose.connection;
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function() {
    console.log('DB connection ready!');
});