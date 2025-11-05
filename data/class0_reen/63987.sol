


pragma solidity ^0.5.0;






contract ERC20Details is TokenDetails {

    uint8 internal _decimals;

    


    function decimals() public view returns(uint8) {
        return _decimals;
    }

}




pragma solidity ^0.5.0;





