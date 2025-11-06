pragma solidity ^0.4.24;





library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}









contract Regulator is RegulatorStorage {
    
    


    


    modifier onlyValidator() {
        require (isValidator(msg.sender), "Sender must be validator");
        _;
    }

    


    event LogBlacklistedUser(address indexed who);
    event LogRemovedBlacklistedUser(address indexed who);
    event LogSetMinter(address indexed who);
    event LogRemovedMinter(address indexed who);
    event LogSetBlacklistDestroyer(address indexed who);
    event LogRemovedBlacklistDestroyer(address indexed who);
    event LogSetBlacklistSpender(address indexed who);
    event LogRemovedBlacklistSpender(address indexed who);

    



    function setMinter(address _who) public onlyValidator {
        _setMinter(_who);
    }

    



    function removeMinter(address _who) public onlyValidator {
        _removeMinter(_who);
    }

    



    function setBlacklistSpender(address _who) public onlyValidator {
        require(isPermission(APPROVE_BLACKLISTED_ADDRESS_SPENDER_SIG), "Blacklist spending not supported by token");
        setUserPermission(_who, APPROVE_BLACKLISTED_ADDRESS_SPENDER_SIG);
        emit LogSetBlacklistSpender(_who);
    }
    
    



    function removeBlacklistSpender(address _who) public onlyValidator {
        require(isPermission(APPROVE_BLACKLISTED_ADDRESS_SPENDER_SIG), "Blacklist spending not supported by token");
        removeUserPermission(_who, APPROVE_BLACKLISTED_ADDRESS_SPENDER_SIG);
        emit LogRemovedBlacklistSpender(_who);
    }

    



    function setBlacklistDestroyer(address _who) public onlyValidator {
        require(isPermission(DESTROY_BLACKLISTED_TOKENS_SIG), "Blacklist token destruction not supported by token");
        setUserPermission(_who, DESTROY_BLACKLISTED_TOKENS_SIG);
        emit LogSetBlacklistDestroyer(_who);
    }
    

    



    function removeBlacklistDestroyer(address _who) public onlyValidator {
        require(isPermission(DESTROY_BLACKLISTED_TOKENS_SIG), "Blacklist token destruction not supported by token");
        removeUserPermission(_who, DESTROY_BLACKLISTED_TOKENS_SIG);
        emit LogRemovedBlacklistDestroyer(_who);
    }

    




    function setBlacklistedUser(address _who) public onlyValidator {
        _setBlacklistedUser(_who);
    }

    




    function removeBlacklistedUser(address _who) public onlyValidator {
        _removeBlacklistedUser(_who);
    }

    



    function isBlacklistedUser(address _who) public view returns (bool) {
        return (hasUserPermission(_who, BLACKLISTED_SIG));
    }


    



    function isBlacklistSpender(address _who) public view returns (bool) {
        return hasUserPermission(_who, APPROVE_BLACKLISTED_ADDRESS_SPENDER_SIG);
    }

    



    function isBlacklistDestroyer(address _who) public view returns (bool) {
        return hasUserPermission(_who, DESTROY_BLACKLISTED_TOKENS_SIG);
    }

    



    function isMinter(address _who) public view returns (bool) {
        return (hasUserPermission(_who, MINT_SIG) && hasUserPermission(_who, MINT_CUSD_SIG));
    }

    

    function _setMinter(address _who) internal {
        require(isPermission(MINT_SIG), "Minting not supported by token");
        require(isPermission(MINT_CUSD_SIG), "Minting to CUSD not supported by token");
        setUserPermission(_who, MINT_SIG);
        setUserPermission(_who, MINT_CUSD_SIG);
        emit LogSetMinter(_who);
    }

    function _removeMinter(address _who) internal {
        require(isPermission(MINT_SIG), "Minting not supported by token");
        require(isPermission(MINT_CUSD_SIG), "Minting to CUSD not supported by token");
        removeUserPermission(_who, MINT_CUSD_SIG);
        removeUserPermission(_who, MINT_SIG);
        emit LogRemovedMinter(_who);
    }

    function _setBlacklistedUser(address _who) internal {
        require(isPermission(BLACKLISTED_SIG), "Self-destruct method not supported by token");
        setUserPermission(_who, BLACKLISTED_SIG);
        emit LogBlacklistedUser(_who);
    }

    function _removeBlacklistedUser(address _who) internal {
        require(isPermission(BLACKLISTED_SIG), "Self-destruct method not supported by token");
        removeUserPermission(_who, BLACKLISTED_SIG);
        emit LogRemovedBlacklistedUser(_who);
    }
}







