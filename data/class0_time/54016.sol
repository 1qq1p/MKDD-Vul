pragma solidity 0.4.24;

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

contract ItemsInterfaceForEternalStorage {
    function createShip(uint256 _itemId) public;
    function createRadar(uint256 _itemId) public;
    function createScanner(uint256 _itemId) public;
    function createDroid(uint256 _itemId) public;
    function createFuel(uint256 _itemId) public;
    function createGenerator(uint256 _itemId) public;
    function createEngine(uint256 _itemId) public;
    function createGun(uint256 _itemId) public;
    function createMicroModule(uint256 _itemId) public;
    function createArtefact(uint256 _itemId) public;
    
    function addItem(string _itemType) public returns(uint256);
}
