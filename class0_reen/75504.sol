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
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
} 
contract Balances is Ownable,
ERC223Token {
    mapping(address => bool)public modules;
    using SafeMath for uint256; 
    address public tokenTransferAddress;  
     function Balances()public {
        
    }
    

    function updateModuleStatus(address _module, bool status)public onlyOwner {
        require(_module != address(0));
        modules[_module] = status;
    }

    function updateTokenTransferAddress(address _tokenAddr)public onlyOwner {
        require(_tokenAddr != address(0));
        tokenTransferAddress = _tokenAddr;

    }

    modifier onlyModule() {
        require(modules[msg.sender] == true);
        _;
    }

    function increaseBalance(address recieverAddr, uint256 _tokens)onlyModule public returns(
        bool
    ) {
        require(recieverAddr != address(0));
        require(balances[tokenTransferAddress] >= _tokens);
        balances[tokenTransferAddress] = balances[tokenTransferAddress].sub(_tokens);
        balances[recieverAddr] = balances[recieverAddr].add(_tokens);
        emit Transfer(tokenTransferAddress,recieverAddr,_tokens);
        return true;
    }
    function decreaseBalance(address recieverAddr, uint256 _tokens)onlyModule public returns(
        bool
    ) {
        require(recieverAddr != address(0));
        require(balances[recieverAddr] >= _tokens);
        balances[recieverAddr] = balances[recieverAddr].sub(_tokens);
        balances[tokenTransferAddress] = balances[tokenTransferAddress].add(_tokens);
        emit Transfer(tokenTransferAddress,recieverAddr,_tokens);
        return true;
    }

   
}
