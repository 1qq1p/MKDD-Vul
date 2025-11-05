






















pragma solidity ^0.4.24;








contract Authority is Ownable {

  address authority;

  


  modifier onlyAuthority {
    require(msg.sender == authority, "AU01");
    _;
  }

  


  function authorityAddress() public view returns (address) {
    return authority;
  }

  




  function defineAuthority(string _name, address _address) public onlyOwner {
    emit AuthorityDefined(_name, _address);
    authority = _address;
  }

  event AuthorityDefined(
    string name,
    address _address
  );
}













