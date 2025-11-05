pragma solidity ^0.4.18;








contract AALMToken is MintableToken, NoOwner { 
    string public symbol = 'AALM';
    string public name = 'Alm Token';
    uint8 public constant decimals = 18;

    address founder;    
    function init(address _founder) onlyOwner public{
        founder = _founder;
    }

    


    modifier canTransfer() {
        require(mintingFinished || msg.sender == founder);
        _;
    }
    
    function transfer(address _to, uint256 _value) canTransfer public returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
}