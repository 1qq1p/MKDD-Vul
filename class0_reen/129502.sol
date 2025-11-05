pragma solidity ^0.4.18;



















library SafeMath3 {

  function mul(uint a, uint b) internal pure returns (uint c) {
    c = a * b;
    assert(a == 0 || c / a == b);
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint c) {
    c = a + b;
    assert(c >= a);
  }

}








contract CaliforniaWildfireRelief_SaintCoinCaller is Owned {
    address saintCoinAddress;
    address fundationWalletAddress;
    uint public percentForHelpCoin = 10;

    function CaliforniaWildfireRelief_SaintCoinCaller(address _saintCoinAddress, address _fundationWalletAddress) public {
        require(_saintCoinAddress != address(0x0));
        require(_fundationWalletAddress != address(0x0));
        
        saintCoinAddress = _saintCoinAddress;
        fundationWalletAddress = _fundationWalletAddress;
    }
    
    function setFoundationAddress(address newFoundationWalletAddress) public onlyOwner {
        fundationWalletAddress = newFoundationWalletAddress;
    }

    function setPercentForHelpCoin(uint _percentForHelpCoin) public onlyOwner {
    	percentForHelpCoin = _percentForHelpCoin;
    }

    function () public payable {
        SaintCoinToken sct = SaintCoinToken(saintCoinAddress);
        sct.sendTo(msg.sender, msg.value);
        
        fundationWalletAddress.transfer(this.balance * (100 - percentForHelpCoin) / 100);
        sct.helpCoinAddress().transfer(this.balance);
    }
}