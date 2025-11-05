pragma solidity ^0.4.23;



contract ParsecReferralTracking {
  mapping (address => address) public referrer;

  event ReferrerUpdated(address indexed _referee, address indexed _referrer);

  function _updateReferrerFor(address _referee, address _referrer) internal {
    if (_referrer != address(0) && _referrer != _referee) {
      referrer[_referee] = _referrer;
      emit ReferrerUpdated(_referee, _referrer);
    }
  }
}


