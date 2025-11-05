contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  



  function Ownable() {
    owner = msg.sender;
  }


  


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  



  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  


  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  


  modifier whenPaused() {
    require(paused);
    _;
  }

  


  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  


  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}