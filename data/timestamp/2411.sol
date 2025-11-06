
pragma solidity ^0.4.24;

























































library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint c) {
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    return a / b;
  }

  function mod(uint a, uint b) internal pure returns (uint) {
    return a % b;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


contract Events {
  event Started (
    uint _time
  );

  event Bought (
    address indexed _player,
    address indexed _referral,
    uint _countryId,
    uint _tickets,
    uint _value,
    uint _excess
  );

  event Promoted (
    address indexed _player,
    uint _goldenTickets,
    uint _endTime
  );

  event Withdrew (
    address indexed _player,
    uint _amount
  );

  event Registered (
    string _code, address indexed _referral
  );

  event Won (
    address indexed _winner, uint _pot
  );
}

