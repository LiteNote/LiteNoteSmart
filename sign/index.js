const ethUtil = require("ethereumjs-util");

const privateKey = 'E9F6B...';
const token = "0x82051cE4f9798E4d5548558BD122B7adff283472";
const to = "0x0851Ee225Df973850ebcE3188A7CAa38BF698572";
const amount = 300000000000000000000;
const fee = 10000000000000000000;
const nonce = 0;

const formattedAddress = (address) => {
    return  Buffer.from(ethUtil.stripHexPrefix(address), 'hex');
};

const formattedInt = (int) => {
    return ethUtil.setLengthLeft(int, 32);
};

const components = [
    formattedAddress(token),
    formattedAddress(to),
    formattedInt(amount),
    formattedInt(fee),
    formattedInt(nonce)
];

const tightPack = Buffer.concat(components);

const hashedTightPack = ethUtil.sha3(tightPack);

const vrs = ethUtil.ecsign(hashedTightPack, Buffer.from(privateKey, 'hex'));
const sig = ethUtil.toRpcSig(vrs.v, vrs.r, vrs.s);


console.log("HASH", ethUtil.bufferToHex(hashedTightPack));
console.log("SIGNATURE", sig);