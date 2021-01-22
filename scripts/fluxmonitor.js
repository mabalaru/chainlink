let abi = [
    {
        "constant": false,
        "inputs": [
            {
                "internalType": "address",
                "name": "oracle",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "recipient",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "name": "withdrawPayment",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "internalType": "address",
                "name": "oracle",
                "type": "address"
            }
        ],
        "name": "withdrawablePayment",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    }
]
var Web3 = require('web3');

// List of Fluxmonitor addresses
contracts = [
['0x0000000000000000000000000000000000000000','YYY/ETH     '],
['0x0000000000000000000000000000000000000000','XXXX/USD    ']
]

node = process.argv[2];
async function run() {
  var web3 = new Web3('ws://GETH_WS:8546');
  var sum = 0
  for (i in contracts) {
    var myContract = new web3.eth.Contract(abi, contracts[i][0]);
    value = await myContract.methods.withdrawablePayment(node).call()
    console.log(contracts[i][0], contracts[i][1], Number(value) / 1000000000000000000)
    sum = sum + Number(value)
  }
  console.log(sum / 1000000000000000000);
  process.exit()
}
run()
