pragma solidity ^0.4.15;






contract EthMessage is Ownable {

    





    uint public constant BASEPRICE = 0.01 ether;
    uint public currentPrice = 0.01 ether;
    string public message = "";

    function withdraw() public payable onlyOwner {
        msg.sender.transfer(this.balance);
    }
    
    
    function removeMessage() onlyOwner public {
        message = "";
    }

    modifier requiresPayment () {
        require(msg.value >= currentPrice);
        if (msg.value > currentPrice) {
            msg.sender.transfer(msg.value - currentPrice);
        }
        currentPrice += BASEPRICE;
        _;
    }

    function putMessage(string messageToPut) public requiresPayment payable {
        if (bytes(messageToPut).length > 255) {
            revert();
        }
        message = messageToPut;
    }

    function () {
        revert();
    }
}