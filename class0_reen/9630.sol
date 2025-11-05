pragma solidity ^0.4.23;











contract FinalizableCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint256;

    bool public isFinalized = false;

    event Finalized();
 
    constructor(address _owner) public Ownable(_owner) {}

    



    function finalize() onlyOwner public {
        require(!isFinalized);
        require(hasEnded());

        finalization();
        emit Finalized();

        isFinalized = true;
    }

    




    function finalization() internal {}
}
