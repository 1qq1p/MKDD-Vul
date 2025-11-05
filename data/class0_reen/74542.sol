pragma solidity ^0.4.14;









library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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






contract SatanCoin is StandardToken {
  
  using SafeMath for uint;

  string public constant name = "SatanCoin";
  string public constant symbol = "SATAN";
  uint public constant decimals = 0;

  address public owner = msg.sender;
  
  uint public constant rate = .0666 ether;

  uint public roundNum = 0;
  uint public constant roundMax = 74;
  uint public roundDeadline;
  bool public roundActive = false;
  uint tokenAmount;
  uint roundBuyersNum;

  mapping(uint => address) buyers;

  event Raffled(uint roundNumber, address winner, uint amount);
  event RoundStart(uint roundNumber);
  event RoundEnd(uint roundNumber);

  modifier onlyOwner {
      require(msg.sender == owner);
      _;
  }

  function ()
    payable
  {
    createTokens(msg.sender);
  }

  function createTokens(address receiver)
    public
    payable
  {
    
    require(roundActive);
    
    require(msg.value > 0);
    
    require((msg.value % rate) == 0);

    tokenAmount = msg.value.div(rate);

    
    require(tokenAmount <= getRoundRemaining());
    
    require((tokenAmount+totalSupply) <= 666);
    
    require(tokenAmount >= 1);

    
    totalSupply = totalSupply.add(tokenAmount);
    balances[receiver] = balances[receiver].add(tokenAmount);

    
    for(uint i = 0; i < tokenAmount; i++)
    {
      buyers[i.add(getRoundIssued())] = receiver;
    }

    
    owner.transfer(msg.value);
  }

  function startRound()
    public
    onlyOwner
    returns (bool)
  {
    require(!roundActive);
    require(roundNum<9); 
     
    roundActive = true;
    roundDeadline = now + 6 days;
    roundNum++;

    RoundStart(roundNum);
    return true;
  }

  function endRound()
    public
    onlyOwner
    returns (bool)
  {
     require(roundDeadline < now);
     
    if(getRoundRemaining() == 74)
    {
      totalSupply = totalSupply.add(74);
      balances[owner] = balances[owner].add(74);
    } 
    else if(getRoundRemaining() != 0) assert(raffle(getRoundRemaining()));

    roundActive = false;

    RoundEnd(roundNum);
    return true;
  }

  function raffle(uint raffleAmount)
    private
    returns (bool)
  {
    
    uint randomIndex = uint(block.blockhash(block.number))%(roundMax-raffleAmount)+1;
    address receiver = buyers[randomIndex];

    totalSupply = totalSupply.add(raffleAmount);
    balances[receiver] = balances[receiver].add(raffleAmount);

    Raffled(roundNum, receiver, raffleAmount);
    return true;
  }

  function getRoundRemaining()
    public
    constant
    returns (uint)
  {
    return roundNum.mul(roundMax).sub(totalSupply);
  }

   function getRoundIssued()
    public
    constant
    returns (uint)
  {
    return totalSupply.sub((roundNum-1).mul(roundMax));
  }
}