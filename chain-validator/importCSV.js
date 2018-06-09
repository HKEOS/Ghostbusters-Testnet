const Eos = require('eosjs');
const fs = require('fs');
const mongoose = require('mongoose'),
    Schema = mongoose.Schema;
Promise = require('bluebird');
mongoose.Promise = Promise;
const parse = require('csv-parse');
require('should');
const config = {
    keyProvider: [''],
    httpEndpoint: 'http://127.0.0.1:8888',
    expireInSeconds: 60,
    broadcast: true,
    debug: false,
    sign: true,
    chainId: '0d6c11e66db1ea0668d630330aaee689aa6aa156a27d39419b64b5ad81c0a760'
};
const eos = Eos(config);

const TokenHolderSchema = new Schema({
    eth: {type: String, unique: true},
    acc: {type: String, unique: true},
    eos: {type: String},
    bal: String,
    proof: Schema.Types.Mixed,
    created: Boolean
});
const TokenHolder = mongoose.model('tokenholder', TokenHolderSchema);
const ProgressBar = require('progress');
const snapshot_json = JSON.parse(fs.readFileSync('snapshot.json', 'utf8'));

let csvData = [];
let bar = null;

function nextRow() {
    bar.tick(1, {});
    const newRow = csvData.shift();
    if (newRow) {
        importRow(newRow);
    } else {
        console.log("Import finished!");
    }
}

function importRow(row) {
    const obj = {
        eth: row[0],
        acc: row[1],
        eos: row[2],
        bal: row[3],
        created: false
    };
    TokenHolder(obj).save((err, data) => {
        if (err) {
            if (err.code === 11000) {
                nextRow();
            } else {
                throw err;
            }
        } else {
            nextRow();
        }
    });
}

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

mongoose.connect('mongodb://localhost/mainnet').then(() => {
    eos['getInfo']({}).then(result => {
        console.log("LIB: " + result['last_irreversible_block_num']);
        parseCSV();
    });
}, (err) => {
    console.log(err);
});