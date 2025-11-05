pragma solidity ^0.4.16;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  address public voiceOfSteelTokenAddress;
  uint256 noEther = 0;

  string public name = "Voice of Steel Token";
  uint8 public decimals = 18;
  string public symbol = "VST";

  address public enterWallet = 0xD7F68D64719401853eC60173891DC1AA7c0ecd71;
  address public investWallet = 0x14c7FBA3C597b53571169Ae2c40CC765303932aE;
  address public exitWallet = 0xD7F68D64719401853eC60173891DC1AA7c0ecd71;
  uint256 public priceEthPerToken = 33333;
  
  uint256 public investCommission = 50;
  uint256 public withdrawCommission = 100;
  bool public availableWithdrawal = false;
  
  event MoreData(uint256 ethAmount, uint256 price);

  




  function transfer(address _to, uint256 _value) whenNotPaused returns (bool) {
    
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    if (_to == voiceOfSteelTokenAddress && availableWithdrawal) {

      uint256 weiAmount = _value.mul(withdrawCommission).div(priceEthPerToken);

      balances[msg.sender] = balances[msg.sender].sub(_value);
      totalSupply = totalSupply.sub(_value);

      msg.sender.transfer(weiAmount);
      exitWallet.transfer(weiAmount.div(100).mul(uint256(100).sub(withdrawCommission)));

      Transfer(msg.sender, voiceOfSteelTokenAddress, _value);
      MoreData(weiAmount, priceEthPerToken);
      return true;

    } else {
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      Transfer(msg.sender, _to, _value);
      MoreData(0, priceEthPerToken);
      return true;
    }
  }

  




  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}
