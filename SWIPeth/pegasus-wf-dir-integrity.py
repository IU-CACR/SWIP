#!/usr/bin/env python

import hashlib
import json
import logging
import optparse
import os
import re
import stat
import sys
from web3 import Web3, HTTPProvider, IPCProvider

# --- global variables ----------------------------------------------------------------

logger = logging.getLogger('my_logger')

#Pegasus User's details
#Using a tester ethereum account for Pegasus User, which will be provided by the user in runtime
wallet_private_key   = "a360cbdaa42c05cae6139c47172ac48429baa3a5eccc375a094775f59e4b6eld"
wallet_address       = "0x27B844444F65266ebcc744F9B51E168d7d2Ef357"


# -------------------------------------------------------------------------------------


def file_sha256(path):
    sha256_hash = hashlib.sha256()
    fd = open(path,'rb')
    for byte_block in iter(lambda: fd.read(4096),b""):
        sha256_hash.update(byte_block)
    fd.close()
    return sha256_hash.hexdigest()


def traverse(wf_dir, sub_dir, found_files_data):

    files = []

    # remove leading /
    sub_dir = re.sub(r'^/+', '', sub_dir)

    logger.debug('Checking directory ' + wf_dir + '/' + sub_dir)
    for entry in sorted(os.listdir(wf_dir + '/' + sub_dir)):
        logger.debug('Found: ' + entry)
        full_path = wf_dir + '/' + sub_dir + '/' + entry
        s = os.stat(full_path)
        # go depth first on subdirs, then process the files
        if stat.S_ISDIR(s.st_mode):
            traverse(wf_dir, sub_dir + '/' + entry, found_files_data)
        elif stat.S_ISREG(s.st_mode):
            files.append(re.sub(r'^/+', '', sub_dir + '/' + entry))
        # ignore everything else

    # now deal with the files
    for entry in files:
        found_files_data.append(entry + '   (' + file_sha256(wf_dir + '/' + entry) + ')')


def generate(wf_dir):
    '''
    Traverses a Pegasus workflow directory and generates a hash for
    integrity purposes
    '''

    found_files_data = []
    traverse(wf_dir, '', found_files_data)
    return found_files_data


def setup_logger(debug_flag):

    # log to the console
    console = logging.StreamHandler()

    # default log level - make logger/console match
    logger.setLevel(logging.INFO)
    console.setLevel(logging.INFO)

    # debug - from command line
    if debug_flag:
        logger.setLevel(logging.DEBUG)
        console.setLevel(logging.DEBUG)

    # formatter
    formatter = logging.Formatter('%(asctime)s %(levelname)7s:  %(message)s')
    console.setFormatter(formatter)
    logger.addHandler(console)
    logger.debug('Logger has been configured')


# --- main ----------------------------------------------------------------------------

def main():

    # Configure command line option parser
    prog_base = os.path.split(sys.argv[0])[1]
    prog_usage = 'usage: %s [options]' % (prog_base)
    parser = optparse.OptionParser(usage=prog_usage)

    parser.add_option('--wf-dir', action='store', dest='wf_dir',
                      help='Full path for the workflow directory to operate on')
    parser.add_option('--generate', action='store_true', dest='generate',
                      help='Generate an integrity structure for a workflow directory')
    parser.add_option('--verify', action='store_true', dest='verify',
                      help='Verify an integrity structure for a workflow directory')
    parser.add_option('-d', '--debug', action = 'store_true', dest = 'debug',
                      help = 'Enables debugging ouput.')

    # Parse command line options
    (options, args) = parser.parse_args()
    setup_logger(options.debug)

    # TODO: handle options / error checking
    current = generate(options.wf_dir)



    
    # ----------------- Select Ethereum node to use!!

    #print("\nEstablishing connection with local Ethereum node ..")
    # Option1: locally running geth node
    #ipc = IPCProvider("/root/.ethereum/testnet/geth.ipc")
    #web3 = Web3(ipc)

    print("\nEstablishing connection with remote Ethereum node (Infura - https://infura.io) ..")
    # Option2: Remote public node provided by Infura (https://infura.io/)
    infura =  HTTPProvider('https://ropsten.infura.io/c4EVd1wpunfDRvJZ3BPr')
    web3 = Web3(infura)

    # Verify the connection with the node
    if not web3.isConnected():
        print("\nUnable to connect to Ethereum Node ..")
    else:
        print("\nSuccessfully Connected ..!!")

      
        
        # --------------  These contract details are constact/fixed
        
        #SWIPETH contract on Ropsten Test Network for Ethereum
        swipeth_address =  web3.toChecksumAddress("0x921cc22021e5caec11322348059abf2efa3233b0")
        
        #ABI Interface for SWIPETH (This is needed to interact with the contract)
        swipeth_interface = """[
        {
	"constant": false,
	"inputs": [
	{
	"name": "key",
	"type": "bytes32"
	},
	{
	"name": "value",
	"type": "bytes32"
	}
	],
	"name": "set",
	"outputs": [],
	"payable": false,
	"stateMutability": "nonpayable",
	"type": "function"
        },
        {
	"constant": true,
	"inputs": [
	{
	"name": "key",
	"type": "bytes32"
	}
	],
	"name": "get",
	"outputs": [
	{
	"name": "",
	"type": "bytes32"
	}
	],
	"payable": false,
	"stateMutability": "view",
	"type": "function"
        }
        ]"""
        
        
        #swipeth is the instance of our Swipeth Contract deployed on the blockchain
        swipeth = web3.eth.contract(address=swipeth_address, abi=swipeth_interface)

        # key is the workflow_id of the current workflow
        key = "0x0000000000000000000000000000000000000000000000000000000000000005"
        
        if options.verify:
            
            #Pull the hash from the blockchain and verify here with hash(current)
            
            #Reading from the blockchain can be done locally using the 'call' method. Not transaction is generated and thus no Gas is required.
            #Retrieve the value using the key from the <key,value> stored on the blockchain
            
            print("\nRetrieving <key,value> from SWIPeth Blockchain contract ..")
            real_hash = swipeth.functions.get(key).call()
            real_hash = web3.toHex(real_hash)
            real_hash_str = str(real_hash)
            print("Key  : {0}\nValue: {1}".format(key, real_hash))

            #Generate hash of 'current'
            current_bytes = str(current).encode()
            sha256_hash = hashlib.sha256()
            sha256_hash.update(current_bytes)
            current_hash = sha256_hash.hexdigest()
            current_hash_str = "0x" + str(current_hash)
            
            #Comapare this hash with the 'current' hash
            print("\nCurrent Hash: {0}".format(current_hash_str))
            
            if current_hash_str == real_hash_str:
                print("\nData Integrity verification successful")
            else:
                print("\nALERT: Data Integrity verification failed")
                
            '''
            f = open(options.verify, 'r')
            truth = json.loads(f.read())
            f.close()
            
            changed_files = list(set(truth).symmetric_difference(set(current)))
            if changed_files:
            for f in changed_files:
            print('Detected changes:   ' + f)
            '''
        else:
            
            #Pushing the hash(current) onto the blockchain (--generate option)

            #Generate hash of 'current'
            current_bytes = str(current).encode()
            sha256_hash = hashlib.sha256()
            sha256_hash.update(current_bytes)
            current_hash = sha256_hash.hexdigest()
            print("\nIntegrity data to be posted on the blockchain: \n\nKey  : {0}\nValue: {1}".format(key,current_hash))
                    
            
            #Estimate the gas required for this transaction
            gas_estimate = swipeth.functions.set(key,current_hash).estimateGas()
            print("\n\nEstimated Gas required for this operation: {0}".format(gas_estimate))
            #Provide available funds and required funds for gas
            #If low funds ..quit
            #else

            balwei = web3.eth.getBalance(wallet_address)
            baleth = web3.fromWei(balwei, 'ether')
            print("Your current balance in wallet {0} is: {1} Ethers".format(wallet_address,baleth))

            suf = input("\nDo you have sufficient funds (Ether) available ? (Y/N): ")
            if suf != 'y' and suf != 'Y':
                print("Aborting operation due to insufficient funds")
            else:
                #use transaction count for user's address as nonce
                nonce = web3.eth.getTransactionCount('0x27B844444F65266ebcc744F9B51E168d7d2Ef357')  
            
                # Build a transaction that invokes this contract's function, called transfer
                
                swipeth_txn = swipeth.functions.set(
                    key,
                    current_hash,
                ).buildTransaction({
                    'chainId': 3,
                    'gas': gas_estimate,
                    'gasPrice': web3.toWei('1', 'gwei'),
                    'nonce': nonce,
                })
                
                #private key of our sample pegasus user
                private_key = "0xa360cbdaa42c05cae6139c47172ac48429baa3a5eccc375a094775f59e4b6e1d"
                
                #sign the transaction using the private key
                signed_txn = web3.eth.account.signTransaction(swipeth_txn, private_key=private_key)
                #tx_hash_unsent = web3.toHex(signed_txn.hash)
                
                
                print("\n\nStoring new <key,value> for the hash of this workflow on the Blockchain.")
                tx_hash = web3.eth.sendRawTransaction(signed_txn.rawTransaction)
                
                print("Please wait while the transaction is mined successfully ..")
                tx_hash = web3.toHex(tx_hash)
                #wait for max 2 mins while transaction is mined, else abort
                tx_receipt = web3.eth.waitForTransactionReceipt(tx_hash, 120)
                
                if tx_receipt != "None":
                    print("\nSWIP Integrity metadata successfully deployed on the Blockchain contract\n\nTransaction: {0}".format(tx_hash))
                else:
                    print("\nOperation failed..please retry")
            
            
if __name__ == '__main__':
    main()
