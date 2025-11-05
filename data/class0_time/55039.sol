pragma solidity ^0.4.18;

contract CryptoCup is Random {

    uint32 public maxNum;
    address public owner;

    event Winner(uint _winnerNum);

    modifier onlyOwner() {require(msg.sender == owner);
        _;}

    constructor() public {
        owner = msg.sender;
    }

    function updateMaxNum(uint32 _num) external onlyOwner {
        maxNum = _num;
    }

    function randomJackpot() external onlyOwner {
        uint winnerNum = random(maxNum);
        emit Winner(winnerNum);
    }
}