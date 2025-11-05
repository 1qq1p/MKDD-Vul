pragma solidity ^0.4.18;






contract Authoreon is StandardToken, Destructible {
    string public constant name = "Authoreon";
    uint public constant decimals = 18;
    string public constant symbol = "AUN";
    function Authoreon()  public {
       totalSupply = 90000000 * (10**decimals);  
       owner = msg.sender;
       balances[msg.sender] = totalSupply;
       Transfer(msg.sender, msg.sender, totalSupply);
    }

    function()  public {
     revert();
    }
   
  
}