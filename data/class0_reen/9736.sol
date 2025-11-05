pragma solidity ^0.4.18;








contract Whitelist is Ownable {
    mapping(address => bool) whitelist;

    uint256 public whitelistLength = 0;

    



  
    function addWallet(address _wallet) onlyOwner public {
        require(_wallet != address(0));
        require(!isWhitelisted(_wallet));
        whitelist[_wallet] = true;
        whitelistLength++;
    }

    



  
    function removeWallet(address _wallet) onlyOwner public {
        require(_wallet != address(0));
        require(isWhitelisted(_wallet));
        whitelist[_wallet] = false;
        whitelistLength--;
    }

    


 
    function isWhitelisted(address _wallet) constant public returns (bool) {
        return whitelist[_wallet];
    }

}


