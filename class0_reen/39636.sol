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
}







contract Affiliate is Ownable {

	
	bool public isAffiliate;

	
	uint256 public affiliateLevel = 1;

	
	mapping(uint256 => uint256) public affiliateRate;

	
	mapping(address => uint256) public referralBalance;

	mapping(address => address) public referral;
	mapping(uint256 => address) public referralIndex;

	uint256 public referralCount;

	
	uint256 public indexPaidAffiliate;

	
	uint256 public maxAffiliate = 100000000*(10**18);

	


	modifier whenAffiliate() {
		require (isAffiliate);
		_;
	}

	


	function Affiliate() public {
		isAffiliate=true;
		affiliateLevel=1;
		affiliateRate[0]=10;
	}

	


	function enableAffiliate() public onlyOwner returns (bool) {
		require (!isAffiliate);
		isAffiliate=true;
		return true;
	}

	


	function disableAffiliate() public onlyOwner returns (bool) {
		require (isAffiliate);
		isAffiliate=false;
		return true;
	}

	


	function getAffiliateLevel() public constant returns(uint256)
	{
		return affiliateLevel;
	}

	



	function setAffiliateLevel(uint256 _level) public onlyOwner whenAffiliate returns(bool)
	{
		affiliateLevel=_level;
		return true;
	}

	



	function getReferrerAddress(address _referee) public constant returns (address)
	{
		return referral[_referee];
	}

	



	function getRefereeAddress(address _referrer) public constant returns (address[] _referee)
	{
		address[] memory refereeTemp = new address[](referralCount);
		uint count = 0;
		uint i;
		for (i=0; i<referralCount; i++){
			if(referral[referralIndex[i]] == _referrer){
				refereeTemp[count] = referralIndex[i];

				count += 1;
			}
		}

		_referee = new address[](count);
		for (i=0; i<count; i++)
			_referee[i] = refereeTemp[i];
	}

	




	function setReferralAddress(address _parent, address _child) public onlyOwner whenAffiliate returns (bool)
	{
		require(_parent != address(0x00));
		require(_child != address(0x00));

		referralIndex[referralCount]=_child;
		referral[_child]=_parent;
		referralCount++;

		referralBalance[_child]=0;

		return true;
	}

	



	function getAffiliateRate(uint256 _level) public constant returns (uint256 rate)
	{
		return affiliateRate[_level];
	}

	




	function setAffiliateRate(uint256 _level, uint256 _rate) public onlyOwner whenAffiliate returns (bool)
	{
		affiliateRate[_level]=_rate;
		return true;
	}

	



	function balanceAffiliateOf(address _referee) public constant returns (uint256)
	{
		return referralBalance[_referee];
	}

	


	function payAffiliate() public onlyOwner returns (bool success);
}





