pragma solidity ^0.4.17;





contract PWL is StandardToken {

            string public name = "PWL";

            string public symbol = "PWL";

            uint8 public decimals = 4;

            uint public INITIAL_SUPPLY = 10000000000000;

             constructor() public {
                
                    totalSupply_ = INITIAL_SUPPLY;
                    balances[msg.sender] = INITIAL_SUPPLY;
                 
            }

}