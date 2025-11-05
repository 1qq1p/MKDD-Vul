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

contract TGE is FixedSupplyCrowdsale, CappedCrowdsale {
    using SafeMath for uint256;
    
    function TGE(
        uint256 _start,
        uint256 _end,
        address _beneficiary,
        address _advisors,
        uint256 _share,
        uint256 _cap,
        uint256 _rate,
        MintableToken _token
        )
        FixedSupplyCrowdsale(
            21000000*10**18,
            _beneficiary,
            _advisors,
            _share
        )
        CappedCrowdsale(
            _cap*10**18
        )
        Crowdsale(
            _start,
            _end,
            _rate,
            _beneficiary
        )
    {
        require(targetSupply.mul(share).div(100) <= targetSupply.sub(cap.mul(rate)));

        token = _token;
    }

    function createTokenContract() internal returns (MintableToken) {
        return MintableToken(0x0);
    }
}