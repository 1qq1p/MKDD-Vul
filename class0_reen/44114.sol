pragma solidity ^0.4.24;








contract ERC1003Token is ERC20 {
    ERC1003Caller public caller_ = new ERC1003Caller();
    address[] internal sendersStack_;

    function approveAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool) {
        sendersStack_.push(msg.sender);
        approve(_to, _value);
        require(caller_.makeCall.value(msg.value)(_to, _data));
        sendersStack_.length -= 1;
        return true;
    }

    function transferAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool) {
        transfer(_to, _value);
        require(caller_.makeCall.value(msg.value)(_to, _data));
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        address from = (_from != address(caller_)) ? _from : sendersStack_[sendersStack_.length - 1];
        return super.transferFrom(from, _to, _value);
    }
}


