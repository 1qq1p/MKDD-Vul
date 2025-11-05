pragma solidity ^0.4.18;















contract IprontoToken is StandardToken {

  
  string public constant name = "iPRONTO";

  
  string public constant symbol = "IPR";

  
  uint8 public constant decimals = 18;

  
  uint256 public constant INITIAL_SUPPLY = 45000000 * (1 ether / 1 wei);

  address public owner;

  
  mapping (address => bool) public validKyc;

  function IprontoToken() public{
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  
  function approveKyc(address[] _addrs)
        public
        onlyOwner
        returns (bool)
    {
        uint len = _addrs.length;
        while (len-- > 0) {
            validKyc[_addrs[len]] = true;
        }
        return true;
    }

  function isValidKyc(address _addr) public constant returns (bool){
    return validKyc[_addr];
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    require(isValidKyc(msg.sender));
    return super.approve(_spender, _value);
  }

  function() public{
    throw;
  }
}

