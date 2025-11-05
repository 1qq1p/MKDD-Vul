pragma solidity ^0.4.24;





library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}






contract TokenControl {
    
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

     
    bool public enablecontrol = true;


    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }
  
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }
    
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }
    
    modifier whenNotPaused() {
        require(enablecontrol);
        _;
    }
    

    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }
    
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }
    
    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }
    
    function enableControl(bool _enable) public onlyCEO{
        enablecontrol = _enable;
    }

  
}







