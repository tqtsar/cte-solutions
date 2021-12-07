
from hexbytes import *
import numpy as np
from sha3 import keccak_256

for i in range(0,256):
    hash = "0x" + keccak_256(np.uint8(i)).hexdigest()
    if hash == '0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365':
        print (i, hash)
