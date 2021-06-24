#! /bin/sh

# all the commits  
declare -a arr=( "d2a3cc65" "90d2192c" "32dd70fc" "9d7b1b98" "b7220ca3" "fb826f9" "31d7d1c" "3660575" "a4bbbfcef6c" "52ea34ab4")

# setup 
# nvm use 10

# keep track of version number
version=0

## now loop through the above array
for commit in "${arr[@]}"
do
   echo "version $version..."
   sh -c "git checkout ${commit}"

   # store in some far away path for now
    dst=$(realpath ../../unlock-versions)

    # create folders
    mkdir -p $dst
    mkdir -p $dst/$version

    # remove deprec deps that throw errors at install
    jq 'del(.devDependencies | .remixd, .remix, .["remix-ide"])' package.json | jq 'del(.dependencies | .truffle, .zos, .["truffle-hdwallet-provider"])'> _p.json && mv _p.json package.json

    # update node_modules
    rm -rf node_modules
    npm i  

    # save hardhat locally to prevent HH12 error
    npm i -S hardhat
    

    # create hardhat config
    echo """
/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const settings = {
  optimizer: {
    enabled: true,
    runs: 200,
  }
}

module.exports = {
  solidity : {
    compilers: [
      { version: '0.4.24', settings },
      { version: '0.4.25', settings },
      { version: '0.5.7', settings },
      { version: '0.5.9', settings },
      { version: '0.5.14', settings },
      { version: '0.5.17', settings },
      { version: '0.6.12', settings },
      { version: '0.7.6', settings },
      { version: '0.8.4', settings },
    ],
  },
};
""" >> hardhat.config.js

    # flatten contracts
    npx hardhat flatten ./contracts/Unlock.sol > "$dst/$version/UnlockV$version.sol"
    npx hardhat flatten ./contracts/PublicLock.sol > "$dst/$version/PublicLockV$version.sol"

    # prevent checkout conflicts
    git checkout package.json package-lock.json
    rm hardhat.config.js
    
    # next version 
    ((version=version+1))
done



## Full run gave two issues for v2 and v5 with
## Error: There is a cycle in the dependency graph, can't compute topological ordering. Files:
## @poanet/solidity-flattener not working either

