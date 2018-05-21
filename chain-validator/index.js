const cp = require('child_process');
const os = require('os'),
    cpuCount = os.cpus().length;
const Eos = require('eosjs');
const ProgressBar = require('progress');
let eos = null;
let bar = null;
const chunks = [];
let totalBlocks = null;
let processedBlocks = 0;

initEOSJS();

function initEOSJS() {
    const config = {
        keyProvider: [],
        httpEndpoint: 'http://aurora.eosrio.io:28888',
        expireInSeconds: 60,
        broadcast: true,
        debug: false,
        sign: false
    };
    eos = Eos.Localnet(config);
    eos['getInfo']({}).then(result => {
        // Get last irreversible block
        const lib_num = result['last_irreversible_block_num'];
        console.log('Starting at block: ' + lib_num);

        const chunkSize = Math.ceil(lib_num / cpuCount);
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
            width: 50,
            total: lib_num
        });

        chunks.forEach((chunk, index) => {
            setTimeout(() => {
                const subNode = cp.fork(`${__dirname}/worker.js`);
                subNode.on('message', (msg) => {
                    if (msg.status === "end") {
                        chunk['low_id'] = msg['data']['id'];
                    }
                    if (msg.status === "recover") {
                        bar.interrupt("Recovered at block -> " + msg.data['blk_num']);
                    }
                    if (msg.status === "block") {
                        processedBlocks = processedBlocks + msg.count;
                        bar.tick(msg.count, {
                            curr: processedBlocks
                        });
                    }
                    if (msg.status === "ready") {
                        subNode.send({
                            high: chunk.high_block,
                            low: chunk.low_block,
                            index: index
                        });
                    }
                });
            }, index * 100);
        });
    });
}