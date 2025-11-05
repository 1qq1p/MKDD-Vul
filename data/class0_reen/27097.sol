pragma solidity ^0.4.24;

library SafeMath {

  


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  


  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    return _a / _b;
  }

  


  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  


  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract TokenVestingPool is Claimable {
  using SafeERC20 for ERC20Basic;
  using SafeMath for uint256;

  
  ERC20Basic public token;

  
  uint256 public totalFunds;

  
  uint256 public distributedTokens;

  
  address[] public beneficiaries;

  
  mapping(address => address[]) public beneficiaryDistributionContracts;

  
  mapping(address => bool) private distributionContracts;

  event BeneficiaryAdded(
    address indexed beneficiary,
    address vesting,
    uint256 amount
  );

  modifier validAddress(address _addr) {
    require(_addr != address(0));
    require(_addr != address(this));
    _;
  }

  





  constructor(
    ERC20Basic _token,
    uint256 _totalFunds
  ) public validAddress(_token) {
    require(_totalFunds > 0);

    token = _token;
    totalFunds = _totalFunds;
    distributedTokens = 0;
  }

  





























  function addBeneficiary(
    address _beneficiary,
    uint256 _start,
    uint256 _cliff,
    uint256 _duration,
    uint256 _amount
  ) public onlyOwner validAddress(_beneficiary) returns (address) {
    require(_beneficiary != owner);
    require(_amount > 0);
    require(_duration >= _cliff);

    
    require(SafeMath.sub(totalFunds, distributedTokens) >= _amount);
    require(token.balanceOf(address(this)) >= _amount);

    if (!beneficiaryExists(_beneficiary)) {
      beneficiaries.push(_beneficiary);
    }

    
    distributedTokens = distributedTokens.add(_amount);

    address tokenVesting = new TokenVesting(
      _beneficiary,
      _start,
      _cliff,
      _duration,
      false 
    );

    
    beneficiaryDistributionContracts[_beneficiary].push(tokenVesting);
    distributionContracts[tokenVesting] = true;

    
    token.safeTransfer(tokenVesting, _amount);

    emit BeneficiaryAdded(_beneficiary, tokenVesting, _amount);
    return tokenVesting;
  }

  




  function getDistributionContracts(
    address _beneficiary
  ) public view validAddress(_beneficiary) returns (address[]) {
    return beneficiaryDistributionContracts[_beneficiary];
  }

  




  function beneficiaryExists(
    address _beneficiary
  ) internal view returns (bool) {
    return beneficiaryDistributionContracts[_beneficiary].length > 0;
  }
}