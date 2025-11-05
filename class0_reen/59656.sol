pragma solidity 0.4.18;






contract TokenOwnable is Standard223Receiver, Ownable {
    
    modifier onlyTokenOwner() {
        require(tkn.sender == owner);
        _;
    }
}









