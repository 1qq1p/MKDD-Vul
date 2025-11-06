pragma solidity ^0.4.18;








contract Whitelist is Ownable {
    mapping(address => bool) whitelist;

    uint256 public whitelistLength = 0;
	
	address private addressApi;
	
	modifier onlyPrivilegeAddresses {
        require(msg.sender == addressApi || msg.sender == owner);
        _;
    }

    




    function setApiAddress(address _api) onlyOwner public {
        require(_api != address(0));

        addressApi = _api;
    }


    



  
    function addWallet(address _wallet) onlyPrivilegeAddresses public {
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

    


 
    function isWhitelisted(address _wallet) view public returns (bool) {
        return whitelist[_wallet];
    }

}








