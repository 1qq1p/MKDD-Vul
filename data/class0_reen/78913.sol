pragma solidity ^0.4.13;






library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}







contract SaleToken is MintableToken, BurnableToken {
    using SafeMath for uint256;

    uint256 public price = 300000000000000000;
    string public constant symbol = "BST";
    string public constant name = "BlockShow Token";
    uint8 public constant decimals = 18;
    uint256 constant level = 10 ** uint256(decimals);
    uint256 public totalSupply = 10000 * level;

    event Payment(uint256 _give, uint256 _get);

    function setPrice(uint256 newPrice) onlyOwner {
        price = newPrice;
    }

    
    function SaleToken() {
        owner = msg.sender;
        balances[owner] = totalSupply;
    }

    




    function() payable {
        buyTo(msg.sender);
    }

    function buyTo(address _to) payable {
        uint256 etherGive = msg.value;
        uint256 tokenGet = (etherGive * level).div(price);

        if(balances[owner] < tokenGet) {
            revert();
        }

        balances[owner] = balances[owner].sub(tokenGet);
        balances[_to] = balances[_to].add(tokenGet);

        Payment(etherGive, tokenGet);
        owner.transfer(etherGive);
    }
}