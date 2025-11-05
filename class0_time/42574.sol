pragma solidity ^0.4.11;




contract ITokenHolder is IOwned {
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
}



