pragma solidity 0.4.18;








contract Contactable is Ownable{

    string public contactInformation;

    



    function setContactInformation(string info) onlyOwner public {
         contactInformation = info;
     }
}







