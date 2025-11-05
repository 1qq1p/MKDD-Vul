pragma solidity 0.4.11;

contract ZENITH is UnlimitedAllowanceToken {

    uint8 constant public decimals = 6;
    uint public totalSupply = 270000000000000;
    string constant public name = "ZENITH TTA";
    string constant public symbol = "ZENITH";
    string messageString = "[ Welcome to the «ZENITH TTA | Tokens Ttansfer Adaptation» Project 0xbt ]";
	mapping (address => mapping (address => uint)) public tokens; 
    event Transfer(address token, address user, uint amount, uint balance);
  
    
    function transferTokenData(address token, address _to, uint _value, string _data) {
    if (token==0) throw;
    if (!Token(token).transferFrom(msg.sender, _to, _value)) throw;
    Transfer(token, _to, _value, tokens[token][msg.sender]);
    }
    
    function getNews() public constant returns (string message) {
        return messageString;
    }
    
    function setNews(string lastNews) public {
        messageString = lastNews;
    }
    
    function ZENITH() {
        balances[msg.sender] = totalSupply;
    }
}