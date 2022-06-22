const path= require('path');
const solc = require('solc');
const fs = require('fs-extra');

const buildPath = path.resolve(__dirname, 'build');
//remove build module
fs.removeSync(buildPath);
const campaignPath = path.resolve(__dirname, 'contracts','Campaign.sol');
//read  content present in file
console.log(campaignPath);
const source = fs.readFileSync(campaignPath, 'utf8');

const input = {
  language: 'Solidity',
  sources: {
    'Campaign.sol': {
      content: source,
    },
  },
  settings: {
    outputSelection: {
      '*': {
        '*': ['*']
      }
    }
  }
};

//compile contract
var output = JSON.parse(solc.compile(JSON.stringify(input)));

//create build folder
fs.ensureDirSync(buildPath);
console.log(output);

const contracts = output.contracts["Campaign.sol"];
for(let contract in contracts){
  fs.outputJsonSync(
      path.resolve(buildPath, contract + '.json'),
      contracts[contract].evm
  );
}
