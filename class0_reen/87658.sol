

pragma solidity ^0.5.0;






contract ERC20Burnable is ERC20 {
    



    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    




    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }
}



pragma solidity ^0.5.4;









