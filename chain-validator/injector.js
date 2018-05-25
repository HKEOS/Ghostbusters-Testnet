const Eos = require('eosjs');
const fs = require('fs');
const mongoose = require('mongoose'),
    Schema = mongoose.Schema;
Promise = require('bluebird');
mongoose.Promise = Promise;
const parse = require('csv-parse');
require('should');
const config = {
    keyProvider: ["5K7U349eNFkgQ86Atb1a4WBsf9jDo3Y6kF2qFCEytjUpN6dMiNN"],
    httpEndpoint: 'http://localhost:8888',
    expireInSeconds: 60,
    broadcast: true,
    debug: false,
    sign: true
};
const eos = Eos.Localnet(config);
let system = null;

const TokenHolderSchema = new Schema({
    eth: {type: String, unique: true},
    acc: {type: String, unique: true},
    eos: {type: String},
    bal: String,
    proof: Schema.Types.Mixed
});
const TokenHolder = mongoose.model('tokenholder', TokenHolderSchema);
const ProgressBar = require('progress');
const snapshot_json = JSON.parse(fs.readFileSync('snapshot.json', 'utf8'));

function nextRow() {
    bar.tick(1, {});
    const newRow = csvData.shift();
    if (newRow) {
        importRow(newRow);
    } else {
        console.log("Import finished!");
        countAccounts().then(() => {
            console.log("Begin on-chain injection...");
            injectOnChain();
        }).catch(() => {
            process.exit(1);
        });
    }
}

function importRow(row) {
    const obj = {
        eth: row[0],
        acc: row[1],
        eos: row[2],
        bal: row[3],
    };
    TokenHolder(obj).save((err, data) => {
        if (err) {
            if (err.code === 11000) {
                bar.interrupt('Duplicate address! skipping...');
                nextRow();
            } else {
                throw err;
            }
        } else {
            nextRow();
        }
    });
}

let csvData = [];
let bar = null;

function parseCSV() {
    csvData = [];
    console.log("Valid accounts: " + snapshot_json.accounts.valid);
    bar = new ProgressBar('  parsing snapshot.csv [:current/:total] [:bar] :rate rows/s :percent :etas', {
        complete: '=',
        incomplete: ' ',
        width: 50,
        total: snapshot_json.accounts.valid
    });
    fs.createReadStream('snapshot.csv').pipe(parse({delimiter: ','})).on('data', (row) => {
        bar.tick(1, {});
        csvData.push(row);
    }).on('end', () => {
        console.log('end!');
        console.log('Rows parsed: ' + csvData.length);
        console.log('Starting database import...');
        bar = new ProgressBar(' >> importing to MongoDB [:current/:total] [:bar] :rate rows/s :percent :etas', {
            complete: '=',
            incomplete: ' ',
            width: 30,
            total: snapshot_json.accounts.valid
        });
        importRow(csvData.shift());
    });
}

function countAccounts() {
    return new Promise((resolve, reject) => {
        TokenHolder.count().then((nAcc) => {
            if (nAcc === snapshot_json.accounts.valid) {
                console.log('Number of imported accounts match!');
                resolve();
            } else {
                console.log('Number of imported accounts do NOT match!');
                reject();
            }
        });
    });
}

function iterateNextDoc(cursor) {
    cursor.next(function (error, item) {
        if (error) {
            throw error;
        } else {
            if (item) {
                newAccount(item['acc'], item['eos'], item['bal']).then((results) => {
                    item.proof = results;
                    item.markModified('proof');
                    item.save((err, data) => {
                        if (err) {
                            console.log('Error while saving proof!');
                        }
                    });
                    bar.tick(1, {
                        account: item['acc']
                    });
                    iterateNextDoc(cursor);
                }, (error) => {
                    console.log('Error2');
                }).catch((err) => {
                    console.log('Error');
                });
            }
        }
    });
}

function injectOnChain() {
    const nrows = 100;
    const jobs = 5;

    // Prepare parallel crsors
    const cursorArray = [];

    bar = new ProgressBar(' >> creating :account and transfering EOS [:current/:total] [:bar] :rate accounts/s :percent :etas', {
        complete: '=',
        incomplete: ' ',
        width: 30,
        total: nrows
    });

    TokenHolder.count().then((docs) => {
        console.log(docs);
        const batchSize = Math.floor(docs / jobs);
        for (let i = 0; i < jobs; i++) {
            const skip = (i * batchSize);
            console.log('Preparing cursor from ' + skip + " to " + (skip + batchSize));
            const temp = TokenHolder.find({}).skip(i).limit(batchSize).cursor();
            cursorArray.push(temp);
        }
        cursorArray.forEach((c) => {
            iterateNextDoc(c);
        })
    });
}

function newAccount(name, pubkey, amount) {
    let split_stake = Math.round((amount / 2) * 10000) / 10000;
    return eos.transaction(tr => {
        tr['newaccount']({
            creator: 'eosio',
            name: name,
            owner: pubkey,
            active: pubkey
        });
        tr['buyrambytes']({
            payer: 'eosio',
            receiver: name,
            bytes: 8192
        });
        tr['delegatebw']({
            from: 'eosio',
            receiver: name,
            stake_net_quantity: split_stake + ' SYS',
            stake_cpu_quantity: split_stake + ' SYS',
            transfer: 0
        });
    });
}

// cleos wallet unlock -n test --password PW5KHF7MX8sce9KPvuPT7ejS4u7a3eAAigsUnoYUTmf3W8ZyscUgH
// Private key: 5JXdpiXVtBXDRt9CQHBgtEvEZvjmpLMnKg5untpVkqiYsVRBQch
// Public key: EOS7pc3PTjQWYY8s1vCayheBaJnYyU5txyoh9UJsxx6kTHr8GSEWj

// Create system accounts

// cleos push action test.token create '[ "eosriobrazil", "10000000000.0000 SYS" ]' -p test.token
// cleos push action test.token issue '[ "eosriobrazil", "1000000000.0000 SYS", "memo" ]' -p test.token

// cleos push action eosio setpriv '["eosio.msig",1]' -p eosio@active

// Private key: 5J5tRfhuAo1pV57NPhFjQfq282Ff8oMQzbP8aZ1eAzSEXJTgjgy
// Public key: EOS8SnD9agkwzbhiPAADF2LoQv83wXTPuR5Qh3bdREQd98eNJDuwB

const accMap = [
    {acc: 'eosio', hash: '1a16bfcbffe1a6115b0c68a3ee2a50fb7c8a86dd227c33db15fa3710716dff98'},
    {acc: 'eosio.token', hash: '641f336aa1d08526201599c3c0ddb7a646e5ac8f9fd2493f56414d0422a0f957'},
    {acc: 'eosio.msig', hash: '5cf017909547b2d69cee5f01c53fe90f3ab193c57108f81a17f0716a4c83f9c0'},
];
function verifyContractCode(ct, idx) {
    console.log("Validating " + ct['acc'] + "...");
    eos['getCode']({account_name: ct['acc']}).then((data) => {
        if (data['code_hash'] === ct['hash']) {
            console.log(data['account_name'] + " >> " + data['code_hash']);
            idx++;
            if (idx < accMap.length) {
                verifyContractCode(accMap[idx], idx);
            } else {
                console.log("Contract code validation completed!");
            }
        } else {
            console.log("Invalid contract code!");
            console.log("Received: " + data['code_hash']);
            console.log("Expected: " + ct['hash']);
            console.log("Quitting! Chain validation failed!");
            process.exit(1);
        }
    });
}

mongoose.connect('mongodb://localhost/validator').then(() => {
    eos['getInfo']({}).then(result => {
        console.log("LIB: " + result['last_irreversible_block_num']);

        verifyContractCode(accMap[0], 0);

        // eos.contract('eosio').then((code) => {
        //     system = code;
        //     console.log(system);
        // });
        // parseCSV();
        // injectOnChain();
    });
}, (err) => {
    console.log(err);
});