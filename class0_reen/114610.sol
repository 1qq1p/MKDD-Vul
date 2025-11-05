pragma solidity ^0.4.17;

contract IABToken is AccessControl {
 
 
    function balanceOf(address owner) public view returns (uint256);
    function totalSupply() external view returns (uint256) ;
    function ownerOf(uint256 tokenId) public view returns (address) ;
    function setMaxAngels() external;
    function setMaxAccessories() external;
    function setMaxMedals()  external ;
    function initAngelPrices() external;
    function initAccessoryPrices() external ;
    function setCardSeriesPrice(uint8 _cardSeriesId, uint _newPrice) external;
    function approve(address to, uint256 tokenId) public;
    function getRandomNumber(uint16 maxRandom, uint8 min, address privateAddress) view public returns(uint8) ;
    function tokenURI(uint256 _tokenId) public pure returns (string memory) ;
    function baseTokenURI() public pure returns (string memory) ;
    function name() external pure returns (string memory _name) ;
    function symbol() external pure returns (string memory _symbol) ;
    function getApproved(uint256 tokenId) public view returns (address) ;
    function setApprovalForAll(address to, bool approved) public ;
    function isApprovedForAll(address owner, address operator) public view returns (bool);
    function transferFrom(address from, address to, uint256 tokenId) public ;
    function safeTransferFrom(address from, address to, uint256 tokenId) public ;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public ;
    function _exists(uint256 tokenId) internal view returns (bool) ;
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) ;
    function _mint(address to, uint256 tokenId) internal ;
    function mintABToken(address owner, uint8 _cardSeriesId, uint16 _power, uint16 _auraRed, uint16 _auraYellow, uint16 _auraBlue, string memory _name, uint16 _experience, uint16 _oldId) public;
    function addABTokenIdMapping(address _owner, uint256 _tokenId) private ;
    function getPrice(uint8 _cardSeriesId) public view returns (uint);
    function buyAngel(uint8 _angelSeriesId) public payable ;
    function buyAccessory(uint8 _accessorySeriesId) public payable ;
    function getAura(uint8 _angelSeriesId) pure public returns (uint8 auraRed, uint8 auraYellow, uint8 auraBlue) ;
    function getAngelPower(uint8 _angelSeriesId) private view returns (uint16) ;
    function getABToken(uint256 tokenId) view public returns(uint8 cardSeriesId, uint16 power, uint16 auraRed, uint16 auraYellow, uint16 auraBlue, string memory name, uint16 experience, uint64 lastBattleTime, uint16 lastBattleResult, address owner, uint16 oldId);
    function setAuras(uint256 tokenId, uint16 _red, uint16 _blue, uint16 _yellow) external;
    function setName(uint256 tokenId,string memory namechange) public ;
    function setExperience(uint256 tokenId, uint16 _experience) external;
    function setLastBattleResult(uint256 tokenId, uint16 _result) external ;
    function setLastBattleTime(uint256 tokenId) external;
    function setLastBreedingTime(uint256 tokenId) external ;
    function setoldId(uint256 tokenId, uint16 _oldId) external;
    function getABTokenByIndex(address _owner, uint64 _index) view external returns(uint256) ;
    function _burn(address owner, uint256 tokenId) internal ;
    function _burn(uint256 tokenId) internal ;
    function _transferFrom(address from, address to, uint256 tokenId) internal ;
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) internal returns (bool);
    function _clearApproval(uint256 tokenId) private ;
}

