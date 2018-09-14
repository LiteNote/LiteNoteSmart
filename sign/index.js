const ethUtil = require("ethereumjs-util");

const privateKey = 'E9F6B170D1A725B0E7B4C26E1F4BE3AE49B39F614F4205757E46D0C9013B6CEA';
const token = "0xdc04977a2078c8ffdf086d618d1f961b6c546222";
const to = "0x0851Ee225Df973850ebcE3188A7CAa38BF698572";
const amount = 300;
const fee = 10;
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