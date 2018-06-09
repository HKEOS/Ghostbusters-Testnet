const Eos = require('eosjs');
const mongoose = require('mongoose'),
    Schema = mongoose.Schema;
mongoose.Promise = require('bluebird');
const config = {
    keyProvider: [''],
    httpEndpoint: 'http://localhost:8888',
    expireInSeconds: 60,
    broadcast: true,
    debug: false,
    sign: false,
    chainId: 'aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906'
};
const eos = Eos(config);
mongoose.connect('mongodb://localhost/mainnet').then(() => {
    process.send({
        status: 'ready'
    });
}, (err) => {
    console.log(err);
});
const BlockSchema = new Schema({
    blk_id: {type: String, unique: true},
    prev_id: String,
    blk_num: Number,
    checked: Boolean,
    actions: Schema.Types.Mixed
});
const Block = mongoose.model('block', BlockSchema);

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
    creationBlock: String
});
const TokenHolder = mongoose.model('tokenholder', TokenHolderSchema);

let tempBlocks = 0;
const invalidActions = [];
let totalRam = 0;
let totalEOS = 0;

function invalidateAction(action, msg) {
    invalidActions.push(action);
    console.log(action);
    console.log(msg + " by " + JSON.stringify(action.authorization));
    console.log("Chain state is invalid!");
}

const allowedContracts = ['eosio.token', 'eosio.msig', 'eosio', 'eosio.unregd'];
const allowedAmounts = ['2.0000 EOS', '10.0000 EOS', '0.1000 EOS'];
const allowedCPUUsage = [100000000, 200000];
const allowedAccounts = [
    'eosio.token', 'eosio.msig', 'b1',
    'eosio', 'eosio.unregd', 'eosio.ram',
    'eosio.ramfee', 'eosio.names', 'eosio.stake',
    'eosio.saving', 'eosio.bpay', 'eosio.vpay', 'genesisblock'
];

function fetchBlockRecursively(blk, limit, idx) {
    eos['getBlock']({
        block_num_or_id: blk
    }).then((result) => {
        let actions = [];
        if (result['transactions'].length > 0) {
            result['transactions'].forEach((transaction) => {
                if (transaction.status === 'executed') {
                    actions = transaction['trx']['transaction']['actions'];
                    actions.forEach((action) => {
                        // Assert actions
                        if (action.name === 'newaccount' && action.account === 'eosio') {
                            if (action.data.creator !== 'eosio') {
                                invalidateAction(action, "Newaccount action was called");
                            } else {
                                TokenHolder.findOne({acc: action.data.name}).then((data, err) => {
                                    if (err) {
                                        console.log(err);
                                    } else {
                                        if (data) {
                                            data['creationBlock'] = blk;
                                            data['created'] = true;
                                            data.save().then(() => {
                                            }).catch((error) => {
                                                console.log(error);
                                            });
                                        } else {
                                            if (!allowedAccounts.includes(action.data.name)) {
                                                invalidateAction(action, "Newaccount action was called");
                                            }
                                        }
                                    }
                                });
                            }
                        } else if (action.name === 'setabi') {
                            const targetContract = action.data.account;
                            if (!allowedContracts.includes(targetContract)) {
                                invalidateAction(action, "Setabi called on invalid contract");
                            }
                        } else if (action.name === 'buyrambytes') {
                            totalRam += action.data.bytes;
                            process.send({
                                status: 'buyrambytes',
                                bytes: action.data.bytes
                            });
                        } else if (action.name === 'delegatebw') {
                            if (action.data.from !== 'eosio') {
                                invalidateAction(action, "Invalid delegate bw action");
                            } else {
                                const stake_net = parseFloat(action.data.stake_net_quantity.split(" ")[0]);
                                const stake_cpu = parseFloat(action.data.stake_cpu_quantity.split(" ")[0]);
                                const balance = stake_cpu + stake_net;
                                TokenHolder.findOne({acc: action.data.receiver}).then((data, err) => {
                                    if (err) {
                                        console.log(err);
                                    } else {
                                        eos['getCurrencyBalance']('eosio.token', action.data.receiver).then((token_data) => {
                                            const tokenBalance = parseFloat(token_data[0].split(' ')[0]);
                                            totalEOS += tokenBalance;
                                            const originalBalance = parseFloat(data.bal);
                                            const diff = (originalBalance - tokenBalance - 0.1 - balance);
                                            if (diff < 0.001) {
                                                data['balanceValid'] = true;
                                                data['freeBalance'] = tokenBalance;
                                                data['stakedBalance'] = balance;
                                            } else {
                                                data['balanceValid'] = false;
                                                console.log('Large diff!');
                                            }
                                            data.save().then(() => {
                                            }).catch((error) => {
                                                console.log(error);
                                            });
                                        });
                                    }
                                });
                            }
                        } else if (action.name === 'transfer') {
                            const q = action.data.quantity;
                            if (action.data.memo === 'init') {
                                if (!allowedAmounts.includes(q)) {
                                    invalidateAction(action, "Invalid amount!");
                                }
                            } else {
                                console.log("\n\n");
                                console.log(" >> " + action.data.memo);
                                console.log("\n");
                            }
                        } else if (action.name === 'setparams') {
                            if (!allowedCPUUsage.includes(action.data.params.max_block_cpu_usage)) {
                                invalidateAction(action, "Invalid max_block_cpu_usage!");
                            }
                        } else if (action.name === 'setcode') {
                            const targetContract = action.data.account;
                            if (!allowedContracts.includes(targetContract)) {
                                invalidateAction(action, "Setcode called on invalid contract");
                            }
                        } else if (action.name === 'setpriv') {
                            if (action.data.account !== 'eosio.msig') {
                                invalidateAction(action, "Action not allowed!");
                            }
                        } else if (action.name === 'setprods') {
                            if (action.account !== 'eosio') {
                                invalidateAction(action, "Action not allowed!");
                            }
                        }  else if (action.name === 'setprods') {
                            if (action.account !== 'eosio') {
                                invalidateAction(action, "Action not allowed!");
                            }
                        } else if (action.name === 'updateauth' && action.account === 'eosio') {
                            console.log(action);
                            const targetContract = action.data.account;
                            if (!allowedAccounts.includes(targetContract)) {
                                invalidateAction(action, "updateauth called on invalid contract");
                            }
                        } else if (action.name === 'issue' && action.account === 'eosio.token') {
                            if (action.data.to !== 'eosio') {
                                invalidateAction(action, "Issue not allowed!");
                            }
                        } else if (action.name === 'create' && action.account === 'eosio.token') {
                            if (action.data.issuer !== 'eosio') {
                                invalidateAction(action, "create not allowed!");
                            }
                        } else if (action.name === 'add') {
                            if (action.account !== 'eosio.unregd') {
                                invalidateAction(action, "Issue not allowed!");
                            }
                        } else {
                            invalidateAction(action, "Action not allowed!");
                        }
                    });
                }
            });
        }
        new Block({
            blk_id: result['id'],
            prev_id: result['previous'],
            blk_num: result['block_num'],
            actions: actions
        }).save().then(() => {
            if (result['block_num'] > limit) {
                tempBlocks++;
                if (tempBlocks > 100) {
                    process.send({
                        status: 'block',
                        count: tempBlocks
                    });
                    tempBlocks = 0;
                }
                fetchBlockRecursively(result['previous'], limit, idx)
            } else {
                process.send({
                    status: 'end',
                    data: {
                        id: result['id']
                    }
                });
            }
        }).catch(() => {
            findLastInserted(result['block_num'], limit)
        });
    });
}

function findLastInserted(current, limit) {
    const query = Block.find({blk_num: {"$lt": current, "$gt": limit}}).sort({blk_num: 1}).limit(1);
    query.exec().then((data) => {
        if (data.length > 0) {
            process.send({
                status: 'recover',
                data: data[0]
            });
            console.log('block: ' + data[0]['blk_num']);
            fetchBlockRecursively(data[0]['blk_num'] - 1, limit);
        } else {
            process.send({
                status: 'finishScan'
            });
        }
    }).catch((err) => {
        console.error(err);
    });
}

process.on('message', (m) => {
    console.log(" >> Worker #" + (m.index + 1) + " started! - From " + m.high + " to " + m.low);
    setTimeout(() => {
        fetchBlockRecursively(m.high, m.low, m.index);
    }, 1000);
});
process.on('beforeExit', (code) => {
    console.log(`About to exit with code: ${code}`);
});