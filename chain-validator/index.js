const mongoose = require('mongoose'),
    Schema = mongoose.Schema;
mongoose.Promise = require('bluebird');

const BlockSchema = new Schema({
    blk_id: {type: String, unique: true},
    prev_id: String,
    blk_num: Number
});

const Block = mongoose.model('block', BlockSchema);

const Eos = require('eosjs');
const ProgressBar = require('progress');
let eos = null;
let bar = null;
const chunks = [];
let totalBlocks = null;
let processedBlocks = 0;
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

function findLastInserted(current, limit) {
    console.log('Searching for lower number inserted...');
    const query = Block.find({blk_num: {"$lt": current, "$gt": limit}}).sort({blk_num: 1}).limit(1);
    query.exec().then((data) => {
        bar.interrupt("Recovered at block -> " + data[0]['blk_num']);
        fetchBlockRecursively(data[0]['blk_num'] - 1, limit);
    }).catch((err) => {
        console.error(err);
    });
}

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
        // Get last irreversible block
        const lib_num = result['last_irreversible_block_num'];
        console.log('Starting at block: ' + lib_num);

        const chunkSize = 100000;
        let b = lib_num;
        totalBlocks = lib_num;
        while (b > 1) {
            let low = b - chunkSize;
            if (low < 1) {
                low = 1;
            }
            chunks.push({
                high_block: b,
                high_id: "",
                low_block: low,
                low_id: ""
            });
            b = low;
        }

        bar = new ProgressBar('  reading blocks [:curr/:total] [:bar] :rate/bps :percent :etas', {
            complete: '=',
            incomplete: ' ',
            width: 40,
            total: lib_num
        });
        chunks.forEach((chunk, index) => {
            fetchBlockRecursively(chunk.high_block, chunk.low_block, index);
        });
    });
}

function fetchBlockRecursively(blk, limit, idx) {
    eos.getBlock({
        block_num_or_id: blk
    }).then((result) => {
        // console.log(result['timestamp'] + " | " + result['block_num']);
        processedBlocks++;
        bar.tick(1, {
            curr: processedBlocks
        });
        new Block({
            blk_id: result['id'],
            prev_id: result['previous'],
            blk_num: result['block_num']
        }).save().then(() => {
            if (result['block_num'] > limit) {
                processedBlocks++;
                fetchBlockRecursively(result['previous'], limit, idx)
            } else {
                console.log('Process reached limit');
                chunks[idx]['low_id'] = result['id'];
            }
        }).catch(() => {
            console.log('Duplicate found...');
            findLastInserted(result['block_num'], limit)
        });
    });
}