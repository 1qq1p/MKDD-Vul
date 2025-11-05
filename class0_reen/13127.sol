pragma solidity 0.5.0;

contract StoppableI is OwnedI {
    function isRunning() public view returns(bool contractRunning);
    function setRunSwitch(bool onOff) public returns(bool success);
}
