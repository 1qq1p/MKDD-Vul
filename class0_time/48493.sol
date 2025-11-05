pragma solidity >=0.5.0 <0.6.0;

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

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    



    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    


    function owner() public view returns (address) {
        return _owner;
    }

    


    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    


    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    





    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    



    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    



    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library BytesUtils {
  function isZero(bytes memory b) internal pure returns (bool) {
    if (b.length == 0) {
      return true;
    }
    bytes memory zero = new bytes(b.length);
    return keccak256(b) == keccak256(zero);
  }
}

library DnsUtils {
  function isDomainName(bytes memory s) internal pure returns (bool) {
    byte last = '.';
    bool ok = false;
    uint partlen = 0;

    for (uint i = 0; i < s.length; i++) {
      byte c = s[i];
      if (c >= 'a' && c <= 'z' || c == '_') {
        ok = true;
        partlen++;
      } else if (c >= '0' && c <= '9') {
        partlen++;
      } else if (c == '-') {
        
        if (last == '.') {
          return false;
        }
        partlen++;
      } else if (c == '.') {
        
        if (last == '.' || last == '-') {
          return false;
        }
        if (partlen > 63 || partlen == 0) {
          return false;
        }
        partlen = 0;
      } else {
        return false;
      }
      last = c;
    }
    if (last == '-' || partlen > 63) {
      return false;
    }
    return ok;
  }
}
