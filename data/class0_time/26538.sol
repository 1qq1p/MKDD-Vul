pragma solidity 0.4.23;

contract AssetProxyInterface is ERC20Interface {
    function _forwardApprove(address _spender, uint _value, address _sender) public returns(bool);
    function _forwardTransferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) public returns(bool);
    function _forwardTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference, address _sender) public returns(bool);
    function recoverTokens(ERC20Interface _asset, address _receiver, uint _value) public returns(bool);
    function etoken2() public pure returns(address) {} 
    function etoken2Symbol() public pure returns(bytes32) {} 
}
