pragma solidity ^0.4.24;



library ItemUtils {

    uint256 internal constant UID_SHIFT = 2 ** 0; 
    uint256 internal constant RARITY_SHIFT = 2 ** 32; 
    uint256 internal constant CLASS_SHIFT = 2 ** 36;  
    uint256 internal constant TYPE_SHIFT = 2 ** 46;  
    uint256 internal constant TIER_SHIFT = 2 ** 56; 
    uint256 internal constant NAME_SHIFT = 2 ** 63; 
    uint256 internal constant REGION_SHIFT = 2 ** 70; 
    uint256 internal constant BASE_SHIFT = 2 ** 78;

    function createItem(uint256 _class, uint256 _type, uint256 _rarity, uint256 _tier, uint256 _name, uint256 _region) internal pure returns (uint256 dna) {
        dna = setClass(dna, _class);
        dna = setType(dna, _type);
        dna = setRarity(dna, _rarity);
        dna = setTier(dna, _tier);
        dna = setName(dna, _name);
        dna = setRegion(dna, _region);
    }

    function setUID(uint256 _dna, uint256 _value) internal pure returns (uint256) {
        require(_value < RARITY_SHIFT / UID_SHIFT);
        return setValue(_dna, _value, UID_SHIFT);
    }

    function setRarity(uint256 _dna, uint256 _value) internal pure returns (uint256) {
        require(_value < CLASS_SHIFT / RARITY_SHIFT);
        return setValue(_dna, _value, RARITY_SHIFT);
    }

    function setClass(uint256 _dna, uint256 _value) internal pure returns (uint256) {
        require(_value < TYPE_SHIFT / CLASS_SHIFT);
        return setValue(_dna, _value, CLASS_SHIFT);
    }

    function setType(uint256 _dna, uint256 _value) internal pure returns (uint256) {
        require(_value < TIER_SHIFT / TYPE_SHIFT);
        return setValue(_dna, _value, TYPE_SHIFT);
    }

    function setTier(uint256 _dna, uint256 _value) internal pure returns (uint256) {
        require(_value < NAME_SHIFT / TIER_SHIFT);
        return setValue(_dna, _value, TIER_SHIFT);
    }

    function setName(uint256 _dna, uint256 _value) internal pure returns (uint256) {
        require(_value < REGION_SHIFT / NAME_SHIFT);
        return setValue(_dna, _value, NAME_SHIFT);
    }

    function setRegion(uint256 _dna, uint256 _value) internal pure returns (uint256) {
        require(_value < BASE_SHIFT / REGION_SHIFT);
        return setValue(_dna, _value, REGION_SHIFT);
    }

    function getUID(uint256 _dna) internal pure returns (uint256) {
        return (_dna % RARITY_SHIFT) / UID_SHIFT;
    }

    function getRarity(uint256 _dna) internal pure returns (uint256) {
        return (_dna % CLASS_SHIFT) / RARITY_SHIFT;
    }

    function getClass(uint256 _dna) internal pure returns (uint256) {
        return (_dna % TYPE_SHIFT) / CLASS_SHIFT;
    }

    function getType(uint256 _dna) internal pure returns (uint256) {
        return (_dna % TIER_SHIFT) / TYPE_SHIFT;
    }

    function getTier(uint256 _dna) internal pure returns (uint256) {
        return (_dna % NAME_SHIFT) / TIER_SHIFT;
    }

    function getName(uint256 _dna) internal pure returns (uint256) {
        return (_dna % REGION_SHIFT) / NAME_SHIFT;
    }

    function getRegion(uint256 _dna) internal pure returns (uint256) {
        return (_dna % BASE_SHIFT) / REGION_SHIFT;
    }

    function setValue(uint256 dna, uint256 value, uint256 shift) internal pure returns (uint256) {
        return dna + (value * shift);
    }
}



library StringUtils {

    function concat(string _base, string _value) internal pure returns (string) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        string memory _tmpValue = new string(_baseBytes.length + _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for (i = 0; i < _baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for (i = 0; i < _valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i++];
        }

        return string(_newValue);
    }

    function uint2str(uint i) internal pure returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0) {
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

}








contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  


  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  




  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  




  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}






