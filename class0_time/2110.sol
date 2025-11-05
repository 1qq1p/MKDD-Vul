pragma solidity ^0.4.18;








contract ERC721 is ERC721Abstract
{
	string constant public   name = "CryptoSportZ";
	string constant public symbol = "CSZ";

	uint256 public totalSupply;
	struct Token
	{
		uint256 price;			
		uint256	option;			
	}
	mapping (uint256 => Token) tokens;
	
	
	mapping (uint256 => address) public tokenIndexToOwner;
	
	
	mapping (address => uint256) ownershipTokenCount; 

	
	
	
	mapping (uint256 => address) public tokenIndexToApproved;
	
	function implementsERC721() public pure returns (bool)
	{
		return true;
	}

	function balanceOf(address _owner) public view returns (uint256 count) 
	{
		return ownershipTokenCount[_owner];
	}
	
	function ownerOf(uint256 _tokenId) public view returns (address owner)
	{
		owner = tokenIndexToOwner[_tokenId];
		require(owner != address(0));
	}
	
	
	
	function _approve(uint256 _tokenId, address _approved) internal 
	{
		tokenIndexToApproved[_tokenId] = _approved;
	}
	
	
	
	
	function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
		return tokenIndexToApproved[_tokenId] == _claimant;
	}
	
	function approve( address _to, uint256 _tokenId ) public
	{
		
		require(_owns(msg.sender, _tokenId));

		
		_approve(_tokenId, _to);

		
		Approval(msg.sender, _to, _tokenId);
	}
	
	function transferFrom( address _from, address _to, uint256 _tokenId ) public
	{
		
		require(_approvedFor(msg.sender, _tokenId));
		require(_owns(_from, _tokenId));

		
		_transfer(_from, _to, _tokenId);
	}
	
	function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
		return tokenIndexToOwner[_tokenId] == _claimant;
	}
	
	function _transfer(address _from, address _to, uint256 _tokenId) internal 
	{
		ownershipTokenCount[_to]++;
		tokenIndexToOwner[_tokenId] = _to;

		if (_from != address(0)) 
		{
			ownershipTokenCount[_from]--;
			
			delete tokenIndexToApproved[_tokenId];
			Transfer(_from, _to, _tokenId);
		}

	}
	
	function transfer(address _to, uint256 _tokenId) public
	{
		require(_to != address(0));
		require(_owns(msg.sender, _tokenId));
		_transfer(msg.sender, _to, _tokenId);
	}

}
