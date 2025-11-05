pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

library SafeMath {
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    if (_a == 0) {
      return 0;
    }
    uint256 c = _a * _b;
    require(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); 
    uint256 c = _a / _b;
    return c;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;
    return c;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}


contract AL is owned, TokenERC20 {

    mapping (address => bool) public frozenAccount;

    
    event FrozenFunds(address target, bool frozen);

    
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}

    
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                                              
        require (balanceOf[_from] >= _value);                              
        require (balanceOf[_to] + _value > balanceOf[_to]);                
        require(!frozenAccount[_from]);                                    
        require(!frozenAccount[_to]);                                      
        balanceOf[_from] = SafeMath.sub(balanceOf[_from],_value);          
        balanceOf[_to] = SafeMath.add(balanceOf[_to],_value);              
        emit Transfer(_from, _to, _value);
    }

    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] = SafeMath.add(balanceOf[target],mintedAmount);
        totalSupply = SafeMath.add(totalSupply,mintedAmount); 
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    }

    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

}