pragma solidity ^0.5.0;





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

    



    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract ProxyTokenBurnerRole {
  using Roles for Roles.Role;

  event BurnerAdded(address indexed account);
  event BurnerRemoved(address indexed account);

  Roles.Role private burners;

  constructor() internal {
    _addBurner(msg.sender);
  }

  modifier onlyBurner() {
    require(isBurner(msg.sender), "Sender does not have a burner role");

    _;
  }

  function isBurner(address account) public view returns (bool) {
    return burners.has(account);
  }

  function addBurner(address account) public onlyBurner {
    _addBurner(account);
  }

  function renounceBurner() public {
    _removeBurner(msg.sender);
  }

  function _addBurner(address account) internal {
    burners.add(account);
    emit BurnerAdded(account);
  }

  function _removeBurner(address account) internal {
    burners.remove(account);
    emit BurnerRemoved(account);
  }
}





interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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












