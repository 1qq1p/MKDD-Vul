




pragma solidity ^0.4.21;







contract MintableToken is StandardToken, Ownable {
    uint public totalSupply = 0;
    address private minter;
    bool public mintingEnabled = true;

    modifier onlyMinter() {
        require(minter == msg.sender);
        _;
    }

    function setMinter(address _minter) public onlyOwner {
        minter = _minter;
    }

    function mint(address _to, uint _amount) public onlyMinter {
        require(mintingEnabled);
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(address(0x0), _to, _amount);
    }

    function stopMinting() public onlyMinter {
        mintingEnabled = false;
    }
}



