pragma solidity ^ 0.4.16;

contract SimpleContract is Token {
    
    function SimpleContract() payable Token() {}
    
    function withdraw() public onlyOwner {
        owner.transfer(this.balance);
    }
    function killme() public onlyOwner {
        selfdestruct(owner);
    }
}