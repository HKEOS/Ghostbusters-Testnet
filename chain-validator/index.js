const mongoose = require('mongoose');
const Eos = require('eosjs');
let eos = null;
mongoose.connect('mongodb://localhost/eos_mainnet');
const db = mongoose.connection;
db.on('error', (err) => {
    console.log(err);
    process.exit(1);
});
db.once('open', () => {
    console.log('DB connection ready!');
    initEOSJS();
});

function initEOSJS() {
    config = {
        keyProvider: [],
        httpEndpoint: 'http://aurora.eosrio.io:28888',
        expireInSeconds: 60,
        broadcast: true,
        debug: false,
        sign: false
    };
    eos = Eos.Localnet(config);
    eos.getInfo({}).then(result => {
        console.log(result);
        // Get last irreversible block
        const lib_num = result['last_irreversible_block_num'];
        fetchBlockRecursively(lib_num);
    });
}

function fetchBlockRecursively(blk) {
    eos.getBlock({
        block_num_or_id: blk
    }).then((result) => {
        // console.log(result);
        console.log(result['timestamp'] + " | " + result['block_num']);
        if (result['block_num'] > 1) {
            fetchBlockRecursively(result['previous'])
        }
    });
}