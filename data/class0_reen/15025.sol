pragma solidity ^0.4.22;

contract FreezeableToken is StandardToken, Freezeable {
    

    

    

    
    function transfer(address to, uint256 value) public whenNotFreezed returns (bool) {
      return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotFreezed returns (bool) {
      return super.transferFrom(from, to, value);
    }

    function approve(address agent, uint256 value) public whenNotFreezed returns (bool) {
      return super.approve(agent, value);
    }

    function increaseApproval(address agent, uint value) public whenNotFreezed returns (bool success) {
      return super.increaseApproval(agent, value);
    }

    function decreaseApproval(address agent, uint value) public whenNotFreezed returns (bool success) {
      return super.decreaseApproval(agent, value);
    }

    
}
