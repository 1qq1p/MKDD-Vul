pragma solidity ^0.4.18;





library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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







contract Platform {
    mapping(bytes32 => address) public proxies;
    function name(bytes32 _symbol) public view returns (string);
    function setProxy(address _address, bytes32 _symbol) public returns (uint errorCode);
    function isOwner(address _owner, bytes32 _symbol) public view returns (bool);
    function totalSupply(bytes32 _symbol) public view returns (uint);
    function balanceOf(address _holder, bytes32 _symbol) public view returns (uint);
    function allowance(address _from, address _spender, bytes32 _symbol) public view returns (uint);
    function baseUnit(bytes32 _symbol) public view returns (uint8);
    function proxyTransferWithReference(address _to, uint _value, bytes32 _symbol, string _reference, address _sender) public returns (uint errorCode);
    function proxyTransferFromWithReference(address _from, address _to, uint _value, bytes32 _symbol, string _reference, address _sender) public returns (uint errorCode);
    function proxyApprove(address _spender, uint _value, bytes32 _symbol, address _sender) public returns (uint errorCode);
    function issueAsset(bytes32 _symbol, uint _value, string _name, string _description, uint8 _baseUnit, bool _isReissuable) public returns (uint errorCode);
    function reissueAsset(bytes32 _symbol, uint _value) public returns (uint errorCode);
    function revokeAsset(bytes32 _symbol, uint _value) public returns (uint errorCode);
    function isReissuable(bytes32 _symbol) public view returns (bool);
    function changeOwnership(bytes32 _symbol, address _newOwner) public returns (uint errorCode);
}
