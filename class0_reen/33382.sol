

















pragma solidity ^0.4.23;







contract WhitelistedCrowdsale is Crowdsale, Ownable {
    mapping (address => bool) private whitelist;

    event WhitelistedAddressAdded(address indexed _address);
    event WhitelistedAddressRemoved(address indexed _address);

    



    modifier onlyIfWhitelisted(address _buyer) {
        require(whitelist[_buyer]);
        _;
    }

    


    function addAddressToWhitelist(address _address) external onlyOwner {
        whitelist[_address] = true;
        emit WhitelistedAddressAdded(_address);
    }

    


    function addAddressesToWhitelist(address[] _addresses) external onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = true;
            emit WhitelistedAddressAdded(_addresses[i]);
        }
    }

    


    function removeAddressFromWhitelist(address _address) external onlyOwner {
        delete whitelist[_address];
        emit WhitelistedAddressRemoved(_address);
    }

    


    function removeAddressesFromWhitelist(address[] _addresses) external onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            delete whitelist[_addresses[i]];
            emit WhitelistedAddressRemoved(_addresses[i]);
        }
    }

    


    function isWhitelisted(address _address) public view returns (bool) {
        return whitelist[_address];
    }

    




    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
        internal
        onlyIfWhitelisted(_beneficiary)
    {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
}


