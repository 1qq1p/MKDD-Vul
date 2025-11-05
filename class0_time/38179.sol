pragma solidity 0.4.24;
 

interface IArbitrage {
    function executeArbitrage(
      address token,
      uint256 amount,
      address dest,
      bytes data
    )
      external
      returns (bool);
}

pragma solidity 0.4.24;


contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}




















pragma solidity 0.4.24;


