














pragma solidity ^0.4.22;








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












interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}













library SafeERC20 {

  using SafeMath for uint256;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    
    
    
    require((value == 0) || (token.allowance(msg.sender, spender) == 0));
    require(token.approve(spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    require(token.approve(spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    require(token.approve(spender, newAllowance));
  }
}









contract CustomWhitelist is CustomPausable {
  mapping(address => bool) public whitelist;

  event WhitelistAdded(address indexed _account);
  event WhitelistRemoved(address indexed _account);

  
  modifier ifWhitelisted(address _account) {
    require(_account != address(0), "Account cannot be zero address");
    require(isWhitelisted(_account), "Account is not whitelisted");

    _;
  }

  
  
  function addWhitelist(address _account) external whenNotPaused onlyAdmin returns(bool) {
    require(_account != address(0), "Account cannot be zero address");

    if(!whitelist[_account]) {
      whitelist[_account] = true;

      emit WhitelistAdded(_account);
    }

    return true;
  }

  
  
  function addManyWhitelist(address[] _accounts) external whenNotPaused onlyAdmin returns(bool) {
    for(uint8 i = 0;i < _accounts.length;i++) {
      if(_accounts[i] != address(0) && !whitelist[_accounts[i]]) {
        whitelist[_accounts[i]] = true;

        emit WhitelistAdded(_accounts[i]);
      }
    }

    return true;
  }

  
  
  function removeWhitelist(address _account) external whenNotPaused onlyAdmin returns(bool) {
    require(_account != address(0), "Account cannot be zero address");
    if(whitelist[_account]) {
      whitelist[_account] = false;
      emit WhitelistRemoved(_account);
    }

    return true;
  }

  
  
  function removeManyWhitelist(address[] _accounts) external whenNotPaused onlyAdmin returns(bool) {
    for(uint8 i = 0;i < _accounts.length;i++) {
      if(_accounts[i] != address(0) && whitelist[_accounts[i]]) {
        whitelist[_accounts[i]] = false;

        emit WhitelistRemoved(_accounts[i]);
      }
    }
    
    return true;
  }

  
  function isWhitelisted(address _address) public view returns(bool) {
    return whitelist[_address];
  }
}






