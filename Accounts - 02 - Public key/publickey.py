# Info: https://yos.io/2018/11/16/ethereum-signatures/

from eth_account._utils.signing import extract_chain_id, to_standard_v
from eth_account._utils.transactions import serializable_unsigned_transaction_from_dict

from web3.auto.infura.ropsten import w3
from web3 import Web3

tx = w3.eth.getTransaction('0xabc467bedd1d17462fcc7942d0af7874d6f8bdefee2b299c9168a216d3ff0edb')
print(Web3.toHex(tx.hash))

# From the tx, we need the v, r and s values to generate the signature for that key
v = to_standard_v(extract_chain_id(tx.v)[1])
r = Web3.toInt(tx.r)
s = Web3.toInt(tx.s)
signature = w3.eth.account._keys.Signature(vrs=(v, r, s))

# The signature.recover_public_key_from_msg_hash() needs the msg hash before signature, so
# now we need to regenerate the message hash from the transaction values
# This hash involves the gas price, nonce, chainId, message data, value, gas and destination address
tx_msg = {}
tx_msg['gasPrice'] = tx['gasPrice']
tx_msg['nonce'] = tx['nonce']
tx_msg['chainId'] = extract_chain_id(tx.v)[0]
tx_msg['data'] = tx['input']
tx_msg['value'] = tx['value']
tx_msg['gas'] = tx['gas']
tx_msg['to'] = tx['to']

# Using eth_account._utils.transactions functions we can serialize the RLP encoding of the message to recover the pk
# https://github.com/ethereum/eth-account/blob/5558be9ce3fef8fe396c45bb744e377c7af5333d/eth_account/_utils/legacy_transactions.py
pre_sign = serializable_unsigned_transaction_from_dict(tx_msg)
print(signature.recover_public_key_from_msg_hash(pre_sign.hash()))
