pragma solidity ^0.4.13;





library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}






contract SaleToken is StandardToken, Ownable {
    using SafeMath for uint;

    
    string public name;

    string public symbol;

    uint public decimals;

    address public mintAgent;

    
    event UpdatedTokenInformation(string newName, string newSymbol);

    






    function SaleToken(string _name, string _symbol, uint _decimals) {
        name = _name;
        symbol = _symbol;

        decimals = _decimals;
    }

    


    function mint(uint amount) public onlyMintAgent {
        balances[mintAgent] = balances[mintAgent].add(amount);

        totalSupply = balances[mintAgent];
    }

    


    function setTokenInformation(string _name, string _symbol) external onlyOwner {
        name = _name;
        symbol = _symbol;

        
        UpdatedTokenInformation(name, symbol);
    }

    



    function setMintAgent(address mintAgentAddress) external emptyMintAgent onlyOwner {
        mintAgent = mintAgentAddress;
    }

    


    modifier onlyMintAgent() {
        require(msg.sender == mintAgent);
        _;
    }

    modifier emptyMintAgent() {
        require(mintAgent == 0);
        _;
    }

}