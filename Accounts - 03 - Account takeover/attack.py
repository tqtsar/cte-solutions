# Info: https://www.instructables.com/Understanding-how-ECDSA-protects-your-data/

import ecdsa
import libnum
import eth_account

from eth_account._utils.signing import extract_chain_id, to_standard_v
from eth_account._utils.transactions import serializable_unsigned_transaction_from_dict

from web3.auto.infura.ropsten import w3
from web3 import Web3

contract_address  = '0xB5aE793b0428ce63368fF984a761E8577b80AA01'
contract_abi      = '[{ "constant": false, "inputs": [], "name": "authenticate", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "isComplete", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "view", "type": "function" }]'
contract_instance = w3.eth.contract(address=contract_address, abi=contract_abi)

# Auxilliary function to create a pre-signature RLP encoded transaction
def createUnsignedTransaction(transaction):
    tx_msg = {}
    tx_msg['gasPrice'] = transaction['gasPrice']
    tx_msg['nonce'] = transaction['nonce']
    tx_msg['chainId'] = extract_chain_id(transaction.v)[0]
    tx_msg['data'] = transaction['input']
    tx_msg['value'] = transaction['value']
    tx_msg['gas'] = transaction['gas']
    tx_msg['to'] = transaction['to']

    return serializable_unsigned_transaction_from_dict(tx_msg)

def solveChallenge(secret_key):
    account = '0x6B477781b0e68031109f21887e6B5afEAaEB002b'
    
    # Get nonce and create a new transaction
    nonce = w3.eth.getTransactionCount(account)
    txn = contract_instance.functions.authenticate().buildTransaction({
        'gas': 2000000,
        'gasPrice': w3.toWei('2', 'gwei'),
        'nonce': nonce
    })

    # Sign the transaction and send it to miners
    txn_signed = w3.eth.account.sign_transaction(txn, private_key=secret_key)
    txn_hash   = w3.eth.send_raw_transaction(txn_signed.rawTransaction)

    print('Transaction sent: ' + Web3.toHex(txn_hash))

G = ecdsa.SECP256k1.generator
order = int(G.order())

tx1 = w3.eth.getTransaction('0xd79fc80e7b787802602f3317b7fe67765c14a7d40c3e0dcb266e63657f881396')
tx2 = w3.eth.getTransaction('0x061bf0b4b5fdb64ac475795e9bc5a3978f985919ce6747ce2cfbbcaccaf51009')

# Check that they have effectively the same r
if Web3.toInt(tx1.r) == Web3.toInt(tx2.r):
    print('Both share r: ' + str(Web3.toHex(tx1.r)) + '\n')
else:
    exit()

# First tx hash reconstruction
presign1 = createUnsignedTransaction(tx1)
presign2 = createUnsignedTransaction(tx2)

# Values used later
z1 = Web3.toInt(presign1.hash())
z2 = Web3.toInt(presign2.hash())

r1 = Web3.toInt(tx1.r)
r2 = Web3.toInt(tx2.r)

s1 = Web3.toInt(tx1.s)
s2 = Web3.toInt(tx2.s)

# Now we need both hashes and both S values, to calculate k
# k = (hash1 - hash2) / (s1 - s2)   --- the s1 and s2 signs can be + or -, so all combinations should be tested
dif_hashes = z1 - z2
sign_variations = [s1 - s2, s1 + s2, -s1 - s2, -s1 - s2]

for variation in sign_variations:
    k = (dif_hashes * libnum.invmod(variation, order)) % order
    d = (((s1 * k - z1) % order) * libnum.invmod(r1, order)) % order

    a = eth_account.Account.from_key(d)
    if a.address == tx1['from']:
        print('Secret key : ' + str(Web3.toHex(d)))
        solveChallenge(d)
        exit()
    