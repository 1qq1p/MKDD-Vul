pragma solidity ^0.4.24;






interface ERC165 {

  





  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);
}






contract RoxOnlyOwnerMethods is RoxBase {
    


    function setApprovedContractAddress (address _contractAddress, bool _value) public onlyOwner {
        ApprovedContractAddress[_contractAddress] = _value;
    }

    


    function setURIToken(string _uriToken) public onlyOwner {
        URIToken = _uriToken;
    }

    


    function setCommissionAddress (address _commissionAddress) public onlyOwner {
        commissionAddress = _commissionAddress;
    }
    


    function setMinterAddress (address _minterAddress) public onlyOwner{
        minter = _minterAddress;
    }

    


    function adminBurnToken(uint256 _tokenId) public onlyOwner {
        _burn(_tokenId);
    }
}




