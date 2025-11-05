pragma solidity ^0.4.23;



contract ParsecShipInfo {
  uint256 public constant TOTAL_SHIP = 900;
  uint256 public constant TOTAL_ARK = 100;
  uint256 public constant TOTAL_HAWKING = 400;
  uint256 public constant TOTAL_SATOSHI = 400;

  uint256 public constant NAME_NOT_AVAILABLE = 0;
  uint256 public constant NAME_ARK = 1;
  uint256 public constant NAME_HAWKING = 2;
  uint256 public constant NAME_SATOSHI = 3;

  uint256 public constant TYPE_NOT_AVAILABLE = 0;
  uint256 public constant TYPE_EXPLORER_FREIGHTER = 1;
  uint256 public constant TYPE_EXPLORER = 2;
  uint256 public constant TYPE_FREIGHTER = 3;

  uint256 public constant COLOR_NOT_AVAILABLE = 0;
  uint256 public constant COLOR_CUSTOM = 1;
  uint256 public constant COLOR_BLACK = 2;
  uint256 public constant COLOR_BLUE = 3;
  uint256 public constant COLOR_BROWN = 4;
  uint256 public constant COLOR_GOLD = 5;
  uint256 public constant COLOR_GREEN = 6;
  uint256 public constant COLOR_GREY = 7;
  uint256 public constant COLOR_PINK = 8;
  uint256 public constant COLOR_RED = 9;
  uint256 public constant COLOR_SILVER = 10;
  uint256 public constant COLOR_WHITE = 11;
  uint256 public constant COLOR_YELLOW = 12;

  function getShip(uint256 _shipId)
    external
    pure
    returns (
      uint256 ,
      uint256 ,
      uint256 
    )
  {
    return (
      _getShipName(_shipId),
      _getShipType(_shipId),
      _getShipColor(_shipId)
    );
  }

  function _getShipName(uint256 _shipId) internal pure returns (uint256 ) {
    if (_shipId < 1) {
      return NAME_NOT_AVAILABLE;
    } else if (_shipId <= TOTAL_ARK) {
      return NAME_ARK;
    } else if (_shipId <= TOTAL_ARK + TOTAL_HAWKING) {
      return NAME_HAWKING;
    } else if (_shipId <= TOTAL_SHIP) {
      return NAME_SATOSHI;
    } else {
      return NAME_NOT_AVAILABLE;
    }
  }

  function _getShipType(uint256 _shipId) internal pure returns (uint256 ) {
    if (_shipId < 1) {
      return TYPE_NOT_AVAILABLE;
    } else if (_shipId <= TOTAL_ARK) {
      return TYPE_EXPLORER_FREIGHTER;
    } else if (_shipId <= TOTAL_ARK + TOTAL_HAWKING) {
      return TYPE_EXPLORER;
    } else if (_shipId <= TOTAL_SHIP) {
      return TYPE_FREIGHTER;
    } else {
      return TYPE_NOT_AVAILABLE;
    }
  }

  function _getShipColor(uint256 _shipId) internal pure returns (uint256 ) {
    if (_shipId < 1) {
      return COLOR_NOT_AVAILABLE;
    } else if (_shipId == 1) {
      return COLOR_CUSTOM;
    } else if (_shipId <= 23) {
      return COLOR_BLACK;
    } else if (_shipId <= 37) {
      return COLOR_BLUE;
    } else if (_shipId <= 42) {
      return COLOR_BROWN;
    } else if (_shipId <= 45) {
      return COLOR_GOLD;
    } else if (_shipId <= 49) {
      return COLOR_GREEN;
    } else if (_shipId <= 64) {
      return COLOR_GREY;
    } else if (_shipId <= 67) {
      return COLOR_PINK;
    } else if (_shipId <= 77) {
      return COLOR_RED;
    } else if (_shipId <= 83) {
      return COLOR_SILVER;
    } else if (_shipId <= 93) {
      return COLOR_WHITE;
    } else if (_shipId <= 100) {
      return COLOR_YELLOW;
    } else if (_shipId <= 140) {
      return COLOR_BLACK;
    } else if (_shipId <= 200) {
      return COLOR_BLUE;
    } else if (_shipId <= 237) {
      return COLOR_BROWN;
    } else if (_shipId <= 247) {
      return COLOR_GOLD;
    } else if (_shipId <= 330) {
      return COLOR_GREEN;
    } else if (_shipId <= 370) {
      return COLOR_GREY;
    } else if (_shipId <= 380) {
      return COLOR_PINK;
    } else if (_shipId <= 440) {
      return COLOR_RED;
    } else if (_shipId <= 460) {
      return COLOR_SILVER;
    } else if (_shipId <= 500) {
      return COLOR_WHITE;
    } else if (_shipId <= 540) {
      return COLOR_BLACK;
    } else if (_shipId <= 600) {
      return COLOR_BLUE;
    } else if (_shipId <= 637) {
      return COLOR_BROWN;
    } else if (_shipId <= 647) {
      return COLOR_GOLD;
    } else if (_shipId <= 730) {
      return COLOR_GREEN;
    } else if (_shipId <= 770) {
      return COLOR_GREY;
    } else if (_shipId <= 780) {
      return COLOR_PINK;
    } else if (_shipId <= 840) {
      return COLOR_RED;
    } else if (_shipId <= 860) {
      return COLOR_SILVER;
    } else if (_shipId <= TOTAL_SHIP) {
      return COLOR_WHITE;
    } else {
      return COLOR_NOT_AVAILABLE;
    }
  }
}







library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


