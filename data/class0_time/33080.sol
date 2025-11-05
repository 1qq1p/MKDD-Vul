pragma solidity ^0.4.24; 





contract TheSmartAsset is Transparent {
  uint256 initialSupply;
  uint burned;
  function totally_decrease_the_supply(uint256 amount_to_burn_from_supply) public payable {
        require(balances[msg.sender] >= amount_to_burn_from_supply);
        balances[msg.sender] = balances[msg.sender].sub(amount_to_burn_from_supply);
        burned = amount_to_burn_from_supply / 10 ** 6;
        totalSupply = totalSupply.sub(amount_to_burn_from_supply);
        RealTotalSupply = RealTotalSupply.sub(burned);
  }
}
