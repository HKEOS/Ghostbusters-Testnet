const Eos = require('eosjs');
const mongoose = require('mongoose'),
    Schema = mongoose.Schema;
mongoose.Promise = require('bluebird');

const config = {
    keyProvider: [],
    httpEndpoint: 'http://aurora.eosrio.io:28888',
    expireInSeconds: 60,
    broadcast: true,
    debug: false,
    sign: false
};
const eos = Eos.Localnet(config);

mongoose.connect('mongodb://localhost/eos_mainnet').then(() => {
    process.send({
        status: 'ready'
    });
}, (err) => {
    console.log(err);
});

const BlockSchema = new Schema({
    blk_id: {type: String, unique: true},
    prev_id: String,
    blk_num: Number
});
const Block = mongoose.model('block', BlockSchema);

function fetchBlockRecursively(blk, limit, idx) {
    eos['getBlock']({
        block_num_or_id: blk
    }).then((result) => {
        // console.log(result['timestamp'] + " | " + result['block_num']);
        new Block({
            blk_id: result['id'],
            prev_id: result['previous'],
            blk_num: result['block_num']
        }).save().then(() => {
            if (result['block_num'] > limit) {
                process.send({
                    status: 'block'
                });
                fetchBlockRecursively(result['previous'], limit, idx)
            } else {
                console.log('Process reached limit');
                process.send({
                    status: 'end',
                    data: {
                        id: result['id']
                    }
                });
            }
        }).catch(() => {
            console.log('Duplicate found...');
            findLastInserted(result['block_num'], limit)
        });
    });
}

function findLastInserted(current, limit) {
    console.log('Searching for lower number inserted...');
    const query = Block.find({blk_num: {"$lt": current, "$gt": limit}}).sort({blk_num: 1}).limit(1);
    query.exec().then((data) => {
        if (data.length > 0) {
            process.send({
                status: 'recover',
                data: data[0]
            });
            console.log('block: ' + data[0]['blk_num']);
            fetchBlockRecursively(data[0]['blk_num'] - 1, limit);
        }
    }).catch((err) => {
        console.error(err);
    });
}

process.on('message', (m) => {
    console.log(" Worker #" + (m.index + 1) + " started! - From " + m.high + " to " + m.low);
    fetchBlockRecursively(m.high, m.low, m.index);
});

process.on('beforeExit', (code) => {
    console.log(`About to exit with code: ${code}`);
});