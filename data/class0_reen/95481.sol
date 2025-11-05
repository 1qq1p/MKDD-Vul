

pragma solidity ^0.4.23;







contract DappToken is Ownable, PausableToken, DetailedERC20 {
    constructor(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply)
        DetailedERC20(_name, _symbol, _decimals)
        public
    {
      totalSupply_ = _totalSupply;
      balances[msg.sender] = totalSupply_;
    }

    function setName(string _name) public onlyOwner {
      name = _name;
    }
    function setSymbol(string _symbol) public onlyOwner {
      symbol = _symbol;
    }
}