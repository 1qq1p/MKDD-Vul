pragma solidity ^0.4.24;

pragma solidity ^0.4.24;

pragma solidity ^0.4.24;


pragma solidity ^0.4.24;







contract CuteCoinInterface is ERC20Interface
{
    function mint(address target, uint256 mintedAmount) public;
    function mintBulk(address[] target, uint256[] mintedAmount) external;
    function burn(uint256 amount) external;
}



