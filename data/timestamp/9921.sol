






pragma solidity ^0.4.15;












library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    
    uint c = a / b;
    
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function percent(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c / 100;
  }
}








 
 

contract RealistoToken is MiniMeToken { 

  
  uint256 public checkpointBlock;

  
  address public mayGenerateAddr;

  
  bool tokenGenerationEnabled; 


  modifier mayGenerate() {
    require ( (msg.sender == mayGenerateAddr) &&
              (tokenGenerationEnabled == true) ); 
    _;
  }

  
  function RealistoToken(address _tokenFactory) 
    MiniMeToken(
      _tokenFactory,
      0x0,
      0,
      "Realisto Token",
      18, 
      "REA",
      
      false){
   
    controller = msg.sender;
     tokenGenerationEnabled = true;
    mayGenerateAddr = controller;
  }

  function setGenerateAddr(address _addr) onlyController{
    
    require( _addr != 0x0 );
    mayGenerateAddr = _addr;
  }


  
  
  function () payable {
    revert();
  }

  
  
  
  
  function generate_token_for(address _addrTo, uint _amount) mayGenerate returns (bool) {
    
    
   
    uint curTotalSupply = totalSupply();
    require(curTotalSupply + _amount >= curTotalSupply); 
    uint previousBalanceTo = balanceOf(_addrTo);
    require(previousBalanceTo + _amount >= previousBalanceTo); 
    updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
    updateValueAtNow(balances[_addrTo], previousBalanceTo + _amount);
    Transfer(0, _addrTo, _amount);
    return true;
  }

  
  function generateTokens(address _owner, uint _amount
    ) onlyController returns (bool) {
    revert();
    generate_token_for(_owner, _amount);    
  }


  
  function finalize() mayGenerate {
    tokenGenerationEnabled = false; 
    checkpointBlock = block.number;
  }  
}