pragma solidity 0.4.24;





library SafeMath {

  





  function mul(uint256 a, uint256 b) internal pure returns (uint256 result) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "Error: Unsafe multiplication operation!");
    return c;
  }

  





  function div(uint256 a, uint256 b) internal pure returns (uint256 result) {
    
    uint256 c = a / b;
    
    return c;
  }

  





  function sub(uint256 a, uint256 b) internal pure returns (uint256 result) {
    
    require(b <= a, "Error: Unsafe subtraction operation!");
    return a - b;
  }

  





  function add(uint256 a, uint256 b) internal pure returns (uint256 result) {
    uint256 c = a + b;
    require(c >= a, "Error: Unsafe addition operation!");
    return c;
  }
}




















contract TokenIOAuthority is Ownable {

    
    using TokenIOLib for TokenIOLib.Data;
    TokenIOLib.Data lib;

    



    constructor(address _storageContract) public {
        





        lib.Storage = TokenIOStorage(_storageContract);

        
        owner[msg.sender] = true;
    }

    





    function setRegisteredFirm(string firmName, bool _authorized) public onlyAuthority(firmName, msg.sender) returns (bool success) {
        
        require(
          lib.setRegisteredFirm(firmName, _authorized),
          "Error: Failed to register firm with storage contract! Please check your arguments."
        );
        return true;
    }

    






    function setRegisteredAuthority(string firmName, address authority, bool _authorized) public onlyAuthority(firmName, msg.sender) returns (bool success) {
        
        require(
          lib.setRegisteredAuthority(firmName, authority, _authorized),
          "Error: Failed to register authority for issuer firm with storage contract! Please check your arguments and ensure firmName is registered before allowing an authority of said firm"
        );
        return true;
    }

    




    function getFirmFromAuthority(address authority) public view returns (string firm) {
        return lib.getFirmFromAuthority(authority);
    }

    




    function isRegisteredFirm(string firmName) public view returns (bool status) {
        
        return lib.isRegisteredFirm(firmName);
    }

    





    function isRegisteredToFirm(string firmName, address authority) public view returns (bool registered) {
        
        return lib.isRegisteredToFirm(firmName, authority);
    }

    




    function isRegisteredAuthority(address authority) public view returns (bool registered) {
        
        return lib.isRegisteredAuthority(authority);
    }

    




    function setMasterFeeContract(address feeContract) public onlyOwner returns (bool success) {
        
        require(
          lib.setMasterFeeContract(feeContract),
          "Error: Unable to set master fee contract. Please ensure fee contract has the correct parameters."
        );
        return true;
      }


    modifier onlyAuthority(string firmName, address authority) {
        
        require(owner[authority] || lib.isRegisteredToFirm(firmName, authority),
          "Error: Transaction sender does not have permission for this operation!"
        );
        _;
    }

}