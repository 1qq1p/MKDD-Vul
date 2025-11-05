pragma solidity ^0.4.24;








contract PepeInterface is ERC721{
    function cozyTime(uint256 _mother, uint256 _father, address _pepeReceiver) public returns (bool);
    function getCozyAgain(uint256 _pepeId) public view returns(uint64);
}




pragma solidity ^0.4.24;





