// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IName {
    function name() external view returns (bytes32);
}

contract FuzzyIdentityChallenge {
    bool public isComplete;

    function authenticate() public {
        require(isSmarx(msg.sender));
        require(isBadCode(msg.sender));

        isComplete = true;
    }

    function isSmarx(address addr) internal view returns (bool) {
        return IName(addr).name() == bytes32("smarx");
    }

    function isBadCode(address _addr) internal pure returns (bool) {
        bytes20 addr = bytes20(_addr);
        bytes20 id = hex"000000000000000000000000000000000badc0de";
        bytes20 mask = hex"000000000000000000000000000000000fffffff";

        for (uint256 i = 0; i < 34; i++) {
            if (addr & mask == id) {
                return true;
            }
            mask <<= 4;
            id <<= 4;
        }

        return false;
    }
}

contract Solution is IName {
    
    function name() external view returns (bytes32) {
        return bytes32("smarx");
    }
    
    function solve(address target) public {
        FuzzyIdentityChallenge(target).authenticate();
    }
    
}

contract Deployer {
    
    function getBytecode() public view returns(bytes memory) {
        return abi.encodePacked(type(Solution).creationCode);
    }
    
    function predictAddress(bytes32 salt) public view returns(address) {
        bytes memory code = abi.encodePacked(type(Solution).creationCode);
        address predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(code))))));
        return predictedAddress;
    }
    
    function deployContract(bytes32 salt) public returns(address) {
        bytes memory code = abi.encodePacked(type(Solution).creationCode);
        address addr;
        assembly {
          addr := create2(0, add(code, 0x20), mload(code), salt)
        }
        return(addr);
    }
    
}