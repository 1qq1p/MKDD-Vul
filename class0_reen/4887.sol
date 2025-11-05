



 
 pragma solidity ^0.4.10;










contract ValueToken is Manageable, ERC20StandardToken {
    
    
    ValueTokenAgent valueAgent;

    
    mapping (address => bool) public reserved;

    
    uint256 public reservedAmount;

    function ValueToken() {}

    
    function setValueAgent(ValueTokenAgent newAgent) managerOnly {
        valueAgent = newAgent;
    }

    function doTransfer(address _from, address _to, uint256 _value) internal {

        if (address(valueAgent) != 0x0) {
            
            valueAgent.tokenIsBeingTransferred(_from, _to, _value);
        }

        
        if (reserved[_from]) {
            reservedAmount = safeSub(reservedAmount, _value);
            
        } 
        if (reserved[_to]) {
            reservedAmount = safeAdd(reservedAmount, _value);
            
        }

        
        super.doTransfer(_from, _to, _value);
    }

    
    function getValuableTokenAmount() constant returns (uint256) {
        return totalSupply() - reservedAmount;
    }

    
    function setReserved(address holder, bool state) managerOnly {        

        uint256 holderBalance = balanceOf(holder);
        if (address(valueAgent) != 0x0) {            
            valueAgent.tokenChanged(holder, holderBalance);
        }

        
        if (state) {
            
            reservedAmount = safeAdd(reservedAmount, holderBalance);
        } else {
            
            reservedAmount = safeSub(reservedAmount, holderBalance);
        }

        reserved[holder] = state;
    }
}















