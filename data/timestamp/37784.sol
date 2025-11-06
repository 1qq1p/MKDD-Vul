pragma solidity ^0.4.21;

contract StorageBase is Ownable {

    function withdrawBalance() external onlyOwner returns (bool) {
        
        
        bool res = msg.sender.send(address(this).balance);
        return res;
    }
}
