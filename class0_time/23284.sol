pragma solidity 0.4.25;







































library ECDSA {
  




  function recover(bytes32 hash, bytes signature)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    
    if (signature.length != 65) {
      return (address(0));
    }

    
    
    
    
    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }

    
    if (v < 27) {
      v += 27;
    }

    
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      
      return ecrecover(hash, v, r, s);
    }
  }

  




  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
    
    
    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
    );
  }
}






library SafeMath {
  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); 
    uint256 c = a / b;
    

    return c;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  



  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}






library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  


  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

  


  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

  



  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}


contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() internal {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(msg.sender);
  }

  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}





