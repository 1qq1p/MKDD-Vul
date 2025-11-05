pragma solidity ^0.4.19;

contract BitEyeToken is ERC20Token, Ownable {

  bool public distributed = false;

  function BitEyeToken() public {
    name = "BitEye Token";
    symbol = "BEY";
    decimals = 18;
    totalSupply = 1000000000 * 1e18;
  }

  function distribute(address _bitEyeExAddr, address _operationAddr, address _airdropAddr) public onlyOwner {
    require(!distributed);
    distributed = true;

    balances[_bitEyeExAddr] = 900000000 * 1e18;
    Transfer(address(0), _bitEyeExAddr, 900000000 * 1e18);

    balances[_operationAddr] = 50000000 * 1e18;
    Transfer(address(0), _operationAddr, 50000000 * 1e18);

    balances[_airdropAddr] = 50000000 * 1e18;
    Transfer(address(0), _airdropAddr, 50000000 * 1e18);
  }
}