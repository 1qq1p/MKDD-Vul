pragma solidity ^0.4.24;





interface IERC165 {

  





  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);
}








contract ERC721Full_custom is ERC721_custom, ERC721Enumerable_custom, ERC721Metadata_custom {
  constructor(string name, string symbol) ERC721Metadata_custom(name, symbol)
    public
  {
  }
}


interface PlanetCryptoCoin_I {
    function balanceOf(address owner) external returns(uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);
}

interface PlanetCryptoUtils_I {
    function validateLand(address _sender, int256[] plots_lat, int256[] plots_lng) external returns(bool);
    function validatePurchase(address _sender, uint256 _value, int256[] plots_lat, int256[] plots_lng) external returns(bool);
    function validateTokenPurchase(address _sender, int256[] plots_lat, int256[] plots_lng) external returns(bool);
    function validateResale(address _sender, uint256 _value, uint256 _token_id) external returns(bool);

    
    function strConcat(string _a, string _b, string _c, string _d, string _e, string _f) external view returns (string);
    function strConcat(string _a, string _b, string _c, string _d, string _e) external view returns (string);
    function strConcat(string _a, string _b, string _c, string _d) external view returns (string);
    function strConcat(string _a, string _b, string _c) external view returns (string);
    function strConcat(string _a, string _b) external view returns (string);
    function int2str(int i) external view returns (string);
    function uint2str(uint i) external view returns (string);
    function substring(string str, uint startIndex, uint endIndex) external view returns (string);
    function utfStringLength(string str) external view returns (uint length);
    function ceil1(int256 a, int256 m) external view returns (int256 );
    function parseInt(string _a, uint _b) external view returns (uint);
}

library Percent {

  struct percent {
    uint num;
    uint den;
  }
  function mul(percent storage p, uint a) internal view returns (uint) {
    if (a == 0) {
      return 0;
    }
    return a*p.num/p.den;
  }

  function div(percent storage p, uint a) internal view returns (uint) {
    return a/p.num*p.den;
  }

  function sub(percent storage p, uint a) internal view returns (uint) {
    uint b = mul(p, a);
    if (b >= a) return 0;
    return a - b;
  }

  function add(percent storage p, uint a) internal view returns (uint) {
    return a + mul(p, a);
  }
}


