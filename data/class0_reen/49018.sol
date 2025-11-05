
























pragma solidity ^0.4.24;

















contract MPSBoardSig is BoardSig {

  string public companyName = "MtPelerin Group SA";
  string public country = "Switzerland";
  string public registeredNumber = "CHE-188.552.084";

  


  constructor(address[] _addresses, uint8 _threshold) public
    BoardSig(_addresses, _threshold)
  {
  }
}