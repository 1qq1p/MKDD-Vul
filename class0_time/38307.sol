pragma solidity ^0.4.24;

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

library Config {
    address constant internal BANK = 0xF2058a24B61E5B7cD0Aa6F4CC28f7ff0ecA10FF4;
    uint constant internal INITIAL_SUPPLY = 50000000000000000000000000;

    function bank() internal pure returns (address) {
      return BANK;
    }
    
    function initial_supply() internal pure returns (uint) {
      return INITIAL_SUPPLY;
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

contract Vest is IVest {
  using SafeMath for uint256;
  
  struct Beneficiary {
    address _address;
    uint256 startTime;
    uint256 _amount;
    uint256 _percent;
    bool monthly;
  }

  mapping (address => Beneficiary) beneficiaries;

  mapping (address => uint256) private _vestedBalances;

  uint256 private _totalVested;
  uint256 private beneficiariesCount;

  function totalVested() public view returns (uint256) {
    return _totalVested;
  }

  function vestedOf(address owner) public view returns (uint256) {
    return _vestedBalances[owner];
  }

  function _vest(address to, uint256 value, uint256 percent, bool monthly) internal {
    require(to != address(0));

    _totalVested = _totalVested.add(value);
    _vestedBalances[to] = _vestedBalances[to].add(value);

    addBeneficiary(to, now, value, percent, monthly);
    emit Vest(to, value);
  }

  function totalBeneficiaries() public view returns (uint256) {
    return beneficiariesCount;
  }

  function addBeneficiary (address to, uint256, uint256 value, uint256 percent, bool monthly) internal {
    beneficiariesCount ++;
    beneficiaries[to] = Beneficiary(to, now, value, percent, monthly);
  }
  
  function isBeneficiary (address _address) public view returns (bool) {
    if (beneficiaries[_address]._address != 0) {
      return true;
    } else {
      return false;
    }
  }

  function getBeneficiary (address _address) public view returns (address, uint256, uint256, uint256, bool) {
    Beneficiary storage b = beneficiaries[_address];
    return (b._address, b.startTime, b._amount, b._percent, b.monthly);
  }
  
  function _getLockedAmount(address _address) public view returns (uint256) {
    Beneficiary memory b = beneficiaries[_address];
    uint256 amount = b._amount;
    uint256 percent = b._percent;
    uint256 timeValue = _getTimeValue(_address);
    uint256 calcAmount = amount.mul(timeValue.mul(percent)).div(100);

    if (calcAmount >= amount) {
        return 0;
    } else {
        return amount.sub(calcAmount);
    }
  }
  
  function _getTimeValue(address _address) internal view returns (uint256) {
    Beneficiary memory b = beneficiaries[_address];
    uint256 startTime = b.startTime;
    uint256 presentTime = now;
    uint256 timeValue = presentTime.sub(startTime);
    bool monthly = b.monthly;

    if (monthly) {
      return timeValue.div(10 minutes);
    } else {
      return timeValue.div(120 minutes);  
    }
  }
}
