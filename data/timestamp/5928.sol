pragma solidity ^0.4.24;




pragma solidity ^0.4.23;


contract Affiliate is Ownable {
    mapping(address => bool) public canSetAffiliate;
    mapping(address => address) public userToAffiliate;

    


    function setAffiliateSetter(address _setter) public onlyOwner {
        canSetAffiliate[_setter] = true;
    }

    




    function setAffiliate(address _user, address _affiliate) public {
        require(canSetAffiliate[msg.sender]);
        if (userToAffiliate[_user] == address(0)) {
            userToAffiliate[_user] = _affiliate;
        }
    }

}


