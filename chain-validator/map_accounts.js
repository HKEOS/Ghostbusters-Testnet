const Eos = require('eosjs');
const fs = require('fs');
const async = require('async');
const mongoose = require('mongoose'),
    Schema = mongoose.Schema;
Promise = require('bluebird');
mongoose.Promise = Promise;
require('should');
const config = {
    keyProvider: [''],
    httpEndpoint: 'http://localhost:8888',
    expireInSeconds: 60,
    broadcast: true,
    debug: false,
    sign: true,
    chainId: 'aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906'
};
const eos = Eos(config);

const TokenHolderSchema = new Schema({
    eth: {type: String, unique: true},
    acc: {type: String, unique: true},
    eos: {type: String},
    bal: String,
    proof: Schema.Types.Mixed,
    created: Boolean,
    balanceValid: Boolean,
    stakedBalance: Number,
    freeBalance: Number,
    creationBlock: String,
    buyrefund: Boolean
});
const TokenHolder = mongoose.model('tokenholder', TokenHolderSchema);

const BlockSchema = new Schema({
    blk_id: {type: String, unique: true},
    prev_id: String,
    blk_num: Number,
    checked: Boolean
});
const Block = mongoose.model('block', BlockSchema);

let lastBlock = null;
const failedBlocks = [];
const ProgressBar = require('progress');
let bar = null;
let counter = 0;
const missedAccounts = [];

const stream = fs.createWriteStream("missing_snapshot.csv", {flags: 'a'});

function verifyAccounts() {
    bar = new ProgressBar(' >> Checking accounts [:current/:total] [:bar] :rate accounts/s :percent :etas', {
        complete: '=',
        incomplete: ' ',
        width: 50,
        total: 163929
    });
    TokenHolder.find({}).then((fullAccountMap) => {
        console.log(fullAccountMap.length);
        async.eachSeries(fullAccountMap, (data, callback) => {
            // data.created = false;
            // data.save().then(() => {
            //     bar.tick(1, {});
            //     callback();
            // });
            return eos['getAccount'](data.acc).then((accdata) => {
                if (accdata.voter_info.staked > 0) {
                    bar.tick(1, {});
                    data.created = true;
                    data.save().then(() => {
                        callback();
                    });
                }
            }).catch(() => {
                counter++;
                console.log('Account not found!');
                missedAccounts.push(data.acc);
                data.created = false;
                data.save().then(() => {
                    callback();
                });
                stream.write('"' + data.eth + '","' + data.acc + '","' + data.eos + '","' + data.bal + '"\n');
            });
        }, (err) => {
            if (err) {
                console.log('A file failed to process');
            } else {
                console.log('All files have been processed successfully');
            }
            console.log(missedAccounts);
            stream.end();
        });
    });
}

mongoose.connect('mongodb://localhost/mainnet').then(() => {
    mongoose.connection.dropCollection('blocks');
    eos['getInfo']({}).then(result => {
        console.log("LIB: " + result['last_irreversible_block_num']);
        Block.find({}).sort({blk_num: -1}).cursor().eachAsync((blockData) => {
            return new Promise((resolve, reject) => {
                if (lastBlock === null) {
                    console.log('updating last block...');
                    bar = new ProgressBar(' >> Checking block links [:current/:total] [:bar] :rate blocks/s :percent :etas', {
                        complete: '=',
                        incomplete: ' ',
                        width: 50,
                        total: blockData.blk_num
                    });
                    lastBlock = blockData.prev_id;
                } else {
                    if (lastBlock !== blockData.blk_id) {
                        console.log('Block link failed!');
                        failedBlocks.push();
                        reject();
                    }
                    lastBlock = blockData.prev_id;
                }
                resolve();
                bar.tick(1, {});
            });
        }).catch((err) => {
            console.log("Error processing blocks...");
            console.log(err);
        }).finally(() => {
            console.log('All block links verified!');
            verifyAccounts();
        });
    });
}, (err) => {
    console.log(err);
});