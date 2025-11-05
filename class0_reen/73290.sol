pragma solidity 0.4.19;

contract ZerroXBToken is UnlimitedAllowanceToken {

    uint8 constant public decimals = 3;
    uint public totalSupply = 210000000000; 
    string constant public name = "ZerroXBToken Project 0xbt";
    string constant public symbol = "ZXBT";
    string messageString = "Welcome to the Project 0xbt.net";
    
    function getPost() public constant returns (string) {
        return messageString;
    }
    
    function setPost(string newPost) public {
        messageString = newPost;
    }
    
    function ZerroXBToken() {
        balances[msg.sender] = totalSupply;
    }
}