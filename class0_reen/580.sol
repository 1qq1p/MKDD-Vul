pragma solidity ^0.4.4;

contract Emitter {
    function emitTransfer(address _from, address _to, bytes32 _symbol, uint _value, string _reference);
    function emitIssue(bytes32 _symbol, uint _value, address _by);
    function emitRevoke(bytes32 _symbol, uint _value, address _by);
    function emitOwnershipChange(address _from, address _to, bytes32 _symbol);
    function emitApprove(address _from, address _spender, bytes32 _symbol, uint _value);
    function emitRecovery(address _from, address _to, address _by);
    function emitError(bytes32 _message);
}
