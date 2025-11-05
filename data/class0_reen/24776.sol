pragma solidity ^0.4.18;







library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}








contract Whitelist is Ownable {
    mapping(address => bool) whitelist;

    uint256 public whitelistLength = 0;

    address public backendAddress;

    



  
    function addWallet(address _wallet) public onlyPrivilegedAddresses {
        require(_wallet != address(0));
        require(!isWhitelisted(_wallet));
        whitelist[_wallet] = true;
        whitelistLength++;
    }

    



  
    function removeWallet(address _wallet) public onlyOwner {
        require(_wallet != address(0));
        require(isWhitelisted(_wallet));
        whitelist[_wallet] = false;
        whitelistLength--;
    }

    


 
    function isWhitelisted(address _wallet) constant public returns (bool) {
        return whitelist[_wallet];
    }

    



    function setBackendAddress(address _backendAddress) public onlyOwner {
        require(_backendAddress != address(0));
        backendAddress = _backendAddress;
    }

    


    modifier onlyPrivilegedAddresses() {
        require(msg.sender == owner || msg.sender == backendAddress);
        _;
    }
}


