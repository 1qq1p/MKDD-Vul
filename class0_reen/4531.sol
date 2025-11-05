pragma solidity ^0.4.23;

contract WORLD1Coin is StandardToken {

  

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  string public name;                   
  uint8 public decimals;                
  string public symbol;                 
  string public version = "H1.0";  
  address public owner;
  bool public tokenIsLocked;
  mapping (address => uint256) lockedUntil;

  constructor() public {
    owner = 0x04c63DC704b7F564870961dd2286F75bCb3A98E2;
    totalSupply = 300000000 * 1000000000000000000;
    balances[owner] = totalSupply;                 
    name = "Worldcoin1";                                
    decimals = 18;                                      
    symbol = "WRLD1";                                    
  }

  
  function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);

    if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) {
      revert();
      }
    return true;
  }

  function transfer(address _to, uint256 _value) public returns (bool success) {
    if (msg.sender == owner || !tokenIsLocked) {
      return super.transfer(_to, _value);
    } else {
      revert();
    }
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    if (msg.sender == owner || !tokenIsLocked) {
      return super.transferFrom(_from, _to, _value);
    } else {
      revert();
    }
  }
  
  function killContract() onlyOwner public {
    selfdestruct(owner);
  }

  function lockTransfers() onlyOwner public {
    tokenIsLocked = true;
  }

}