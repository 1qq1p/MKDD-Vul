























pragma solidity ^0.4.24;








contract IMintableByLot is IMintable {
  function minterLotId(address _minter) public view returns (uint256);
}







