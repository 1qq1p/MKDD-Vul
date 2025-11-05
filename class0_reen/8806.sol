pragma solidity ^0.4.23;







library Math {
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



contract PriceChecker is usingOraclize {

  
  address priceCheckerAddress;
  
  string public ETHEUR = "571.85000";
  
  uint256 public fidaPerEther = 57185000;
  
  mapping(bytes32 => bool) public ids;
  
  uint256 gasLimit = 58598;

  




  event PriceUpdated(bytes32 _id, string _price);
  




  event NewOraclizeQuery(bytes32 _id, uint256 _fees);

  




  event OraclizeQueryNotSend(string _description, uint256 _fees);

  



  constructor(address _priceCheckerAddress) public payable {
    priceCheckerAddress = _priceCheckerAddress;

    _updatePrice();
  }

  


  function updatePrice() public payable {
    require(msg.sender == priceCheckerAddress);

    _updatePrice();
  }

  function _updatePrice() private {
    if (oraclize_getPrice("URL", gasLimit) > address(this).balance) {
      emit OraclizeQueryNotSend("Oraclize query was NOT sent, please add some ETH to cover for the query fee", oraclize_getPrice("URL"));
    } else {
      bytes32 id = oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHEUR).result.XETHZEUR.a[0]", gasLimit);
      ids[id] = true;
      emit NewOraclizeQuery(id, oraclize_getPrice("URL"));
    }
  }

  




  function __callback(bytes32 _id, string _result) public {
    require(msg.sender == oraclize_cbAddress());
    require(ids[_id] == true);

    ETHEUR = _result;
    
    fidaPerEther = parseInt(_result, 5);

    emit PriceUpdated(_id, _result);
  }

  


  function changeGasLimit(uint256 _gasLimit) public {
    require(msg.sender == priceCheckerAddress);

    gasLimit = _gasLimit;
  }
}







interface MemberManagerInterface {
  



  event MemberAdded(address indexed member);

  



  event MemberRemoved(address indexed member);

  





  event TokensBought(address indexed member, uint256 tokensBought, uint256 tokens);

  



  function removeMember(address _member) external;

  




  function addAmountBoughtAsMember(address _member, uint256 _amountBought) external;
}







