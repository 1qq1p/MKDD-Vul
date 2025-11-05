pragma solidity ^0.4.25;







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
contract ICO is BaseToken,DateTimeEnabled{

    uint256 base = 10;
    uint256 multiplier;

    address ownerMultisig;

    struct ICOPhase {
        string phaseName;
        uint256 tokensStaged;
        uint256 tokensAllocated;
        uint256 iRate;
        uint256 fRate;
        uint256 intialTime;
        uint256 closingTime;
       
        bool saleOn;
        uint deadline;
    }

    uint8 public currentICOPhase;
    
    mapping(address=>uint256) public ethContributedBy;
    uint256 public totalEthRaised;
    uint256 public totalTokensSoldTillNow;

    mapping(uint8=>ICOPhase) public icoPhases;
    uint8 icoPhasesIndex=1;
    
    function getEthContributedBy(address _address) view public returns(uint256){
        return ethContributedBy[_address];
    }

    function getTotalEthRaised() view public returns(uint256){
        return totalEthRaised;
    }

    function getTotalTokensSoldTillNow() view public returns(uint256){
        return totalTokensSoldTillNow;
    }

    
    function addICOPhase(string _phaseName,uint256 _tokensStaged,uint256 _iRate, uint256 _fRate,uint256 _intialTime,uint256 _closingTime) ownerOnly public{
        icoPhases[icoPhasesIndex].phaseName = _phaseName;
        icoPhases[icoPhasesIndex].tokensStaged = _tokensStaged;
        icoPhases[icoPhasesIndex].iRate = _iRate;
        icoPhases[icoPhasesIndex].fRate = _fRate;
        icoPhases[icoPhasesIndex].intialTime = _intialTime;
        icoPhases[icoPhasesIndex].closingTime = _closingTime;
        icoPhases[icoPhasesIndex].tokensAllocated = 0;
        icoPhases[icoPhasesIndex].saleOn = false;
        
        icoPhasesIndex++;
    }

    function toggleSaleStatus() ownerOnly external{
        icoPhases[currentICOPhase].saleOn = !icoPhases[currentICOPhase].saleOn;
    }
    function changefRate(uint256 _fRate) ownerOnly external{
        icoPhases[currentICOPhase].fRate = _fRate;
    }
    function changeCurrentICOPhase(uint8 _newPhase) ownerOnly external{ 
        currentICOPhase = _newPhase;
    }

    function changeCurrentPhaseDeadline(uint8 _numdays) ownerOnly external{
        icoPhases[currentICOPhase].closingTime= addDaystoTimeStamp(_numdays); 
    }
    
    function transferOwnership(address newOwner) ownerOnly external{
        if (newOwner != address(0)) {
          owner = newOwner;
        }
    }
    
}