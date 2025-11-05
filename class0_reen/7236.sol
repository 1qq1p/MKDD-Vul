pragma solidity ^0.4.18;








contract FFUELCoinToken is MintableToken {
    string public constant name = "FIFO FUEL";
    string public constant symbol = "FFUEL";
    uint8 public decimals = 18;
    bool public tradingStarted = false;

    
    string public constant version = "v2";

    
    mapping (address => bool) public transferable;

    



    modifier allowTransfer(address _spender) {

        require(tradingStarted || transferable[_spender]);
        _;
    }
    





    function modifyTransferableHash(address _spender, bool value) onlyOwner public {
        transferable[_spender] = value;
    }

    


    function startTrading() onlyOwner public {
        tradingStarted = true;
    }

    




    function transfer(address _to, uint _value) allowTransfer(msg.sender) public returns (bool){
        return super.transfer(_to, _value);
    }

    






    function transferFrom(address _from, address _to, uint _value) allowTransfer(_from) public returns (bool){
        return super.transferFrom(_from, _to, _value);
    }

    




    function approve(address _spender, uint256 _value) public allowTransfer(_spender) returns (bool) {
        return super.approve(_spender, _value);
    }

    


    function increaseApproval(address _spender, uint _addedValue) public allowTransfer(_spender) returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    


    function decreaseApproval(address _spender, uint _subtractedValue) public allowTransfer(_spender) returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}










