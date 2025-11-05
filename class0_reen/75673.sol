pragma solidity ^0.4.24;

contract Blacklist is MultiOwnable {
   
    mapping(address => bool) blacklisted;
    
    event TMTG_Blacklisted(address indexed blacklist);
    event TMTG_Whitelisted(address indexed whitelist);

    modifier whenPermitted(address node) {
        require(!blacklisted[node]);
        _;
    }
    
    



    function isPermitted(address node) public view returns (bool) {
        return !blacklisted[node];
    }

    



    function blacklist(address node) public onlyOwner returns (bool) {
        blacklisted[node] = true;
        emit TMTG_Blacklisted(node);

        return blacklisted[node];
    }

    



    function unblacklist(address node) public onlyOwner returns (bool) {
        blacklisted[node] = false;
        emit TMTG_Whitelisted(node);

        return blacklisted[node];
    }
}
