pragma solidity ^0.4.24;







contract ERC721Receiver {

	




	bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;

	












	function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}







library AddressUtils {

	






	function isContract(address _account) internal view returns(bool) 
	{
		uint256 size;
		
		
		
		
		
		
		assembly { size := extcodesize(_account) }
		return size > 0;
	}
}








library StringUtils {

	






	function replace(string _str, string _key, string _value) internal pure returns(string)
	{
		bytes memory bStr = bytes(_str);
		bytes memory bKey = bytes(_key);
		bytes memory bValue = bytes(_value);

		uint index = indexOf(bStr, bKey);
		if (index < bStr.length) {
			bytes memory rStr = new bytes((bStr.length + bValue.length) - bKey.length);

			uint i;
			for (i = 0; i < index; i++) rStr[i] = bStr[i];
			for (i = 0; i < bValue.length; i++) rStr[index + i] = bValue[i];
			for (i = 0; i < bStr.length - (index + bKey.length); i++) rStr[index + bValue.length + i] = bStr[index + bKey.length + i];

			return string(rStr);
		}
		return string(bStr);
	}

	





	function toHexString(uint256 _num, uint _byteSize) internal pure returns(string)
	{
		bytes memory s = new bytes(_byteSize * 2 + 2);
		s[0] = 0x30;
		s[1] = 0x78;
		for (uint i = 0; i < _byteSize; i++) {
			byte b = byte(uint8(_num / (2 ** (8 * (_byteSize - 1 - i)))));
			byte hi = byte(uint8(b) / 16);
			byte lo = byte(uint8(b) - 16 * uint8(hi));
			s[2 + 2 * i] = char(hi);
			s[3 + 2 * i] = char(lo);
		}
		return string(s);
	}

	




	function char(byte _b) internal pure returns(byte c)
	{
		if (_b < 10) return byte(uint8(_b) + 0x30);
		else return byte(uint8(_b) + 0x57);
	}

	





	function indexOf(bytes _str, bytes _key) internal pure returns(uint)
	{
		for (uint i = 0; i < _str.length - (_key.length - 1); i++) {
			bool matchFound = true;
			for (uint j = 0; j < _key.length; j++) {
				if (_str[i + j] != _key[j]) {
					matchFound = false;
					break;
				}
			}
			if (matchFound) {
				return i;
			}
		}
		return _str.length;
	}
}