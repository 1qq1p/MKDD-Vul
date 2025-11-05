pragma solidity ^0.4.18;













library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}





contract C4FEscrow {

    using SafeMath for uint;
    
    address public owner;
    address public requester;
    address public provider;

    uint256 public startTime;
    uint256 public closeTime;
    uint256 public deadline;
    
    uint256 public C4FID;
    uint8   public status;
    bool    public requesterLocked;
    bool    public providerLocked;
    bool    public providerCompleted;
    bool    public requesterDisputed;
    bool    public providerDisputed;
    uint8   public arbitrationCosts;

    event ownerChanged(address oldOwner, address newOwner);   
    event deadlineChanged(uint256 oldDeadline, uint256 newDeadline);
    event favorDisputed(address disputer);
    event favorUndisputed(address undisputer);
    event providerSet(address provider);
    event providerLockSet(bool lockstat);
    event providerCompletedSet(bool completed_status);
    event requesterLockSet(bool lockstat);
    event favorCompleted(address provider, uint256 tokenspaid);
    event favorCancelled(uint256 tokensreturned);
    event tokenOfferChanged(uint256 oldValue, uint256 newValue);
    event escrowArbitrated(address provider, uint256 coinsreturned, uint256 fee);





    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }   

    modifier onlyRequester {
        require(msg.sender == requester);
        _;
    }   
    
    modifier onlyProvider {
        require(msg.sender == provider);
        _;
    }   

    modifier onlyOwnerOrRequester {
        require((msg.sender == owner) || (msg.sender == requester)) ;
        _;
    }   
    
    modifier onlyOwnerOrProvider {
        require((msg.sender == owner) || (msg.sender == provider)) ;
        _;        
    }
    
    modifier onlyProviderOrRequester {
        require((msg.sender == requester) || (msg.sender == provider)) ;
        _;        
    }

    
    
    
    function C4FEscrow(address newOwner, uint256 ID, address req, uint256 deadl, uint8 arbCostPercent) public {
        owner       = newOwner; 
        C4FID       = ID;
        requester   = req;
        provider    = address(0);
        startTime   = now;
        deadline    = deadl;
        status      = 1;        
        arbitrationCosts    = arbCostPercent;
        requesterLocked     = false;
        providerLocked      = false;
        providerCompleted   = false;
        requesterDisputed   = false;
        providerDisputed    = false;
    }
    
    
    
    
    function getOwner() public view returns (address ownner) {
        return owner;
    } 
    
    function setOwner(address newOwner) public onlyOwner returns (bool success) {
        require(newOwner != address(0));
        ownerChanged(owner,newOwner);
        owner = newOwner;
        return true;
    }
    
    
    
    function getRequester() public view returns (address req) {
        return requester;
    }

    
    
    
    function getProvider() public view returns (address prov) {
        return provider;
    }

    
    
    
    function getStartTime() public view returns (uint256 st) {
        return startTime;
    }    

    
    
    
    
    
    function getDeadline() public view returns (uint256 actDeadline) {
        actDeadline = deadline;
        return actDeadline;
    }
    
    
    
    
    
    function changeDeadline(uint newDeadline) public onlyRequester returns (bool success) {
        
        require ((!providerLocked) && (!providerDisputed) && (!providerCompleted) && (status==1));
        deadlineChanged(newDeadline, deadline);
        deadline = newDeadline;
        return true;
    }

    
    
    
    function getStatus() public view returns (uint8 s) {
        return status;
    }

    
    
    
    
    
    function disputeFavor() public onlyProviderOrRequester returns (bool success) {
        if(msg.sender == requester) {
            requesterDisputed = true;
        }
        if(msg.sender == provider) {
            providerDisputed = true;
            providerLocked = true;
        }
        favorDisputed(msg.sender);
        return true;
    }
    
    
    
    function undisputeFavor() public onlyProviderOrRequester returns (bool success) {
        if(msg.sender == requester) {
            requesterDisputed = false;
        }
        if(msg.sender == provider) {
            providerDisputed = false;
        }
        favorUndisputed(msg.sender);
        return true;
    }
    
    
    
    
    
    
    function setProvider(address newProvider) public onlyOwnerOrRequester returns (bool success) {
        
        require(!providerLocked);
        require(!requesterLocked);
        provider = newProvider;
        providerSet(provider);
        return true;
    }
    
    
    
    
    
    
    function setProviderLock(bool lock) public onlyOwnerOrProvider returns (bool res) {
        providerLocked = lock;
        providerLockSet(lock);
        return providerLocked;
    }

    
    
    
    
    function setProviderCompleted(bool c) public onlyOwnerOrProvider returns (bool res) {
        providerCompleted = c;
        providerCompletedSet(c);
        return c;
    }
    
    
    
    
    function setRequesterLock(bool lock) public onlyOwnerOrRequester returns (bool res) {
        requesterLocked = lock;
        requesterLockSet(lock);
        return requesterLocked;
    }
    

    function getRequesterLock() public onlyOwnerOrRequester view returns (bool res) {
        res = requesterLocked;
        return res;
    }


    
    
    
    function setStatus(uint8 newStatus) public onlyOwner returns (uint8 stat) {
        status = newStatus;    
        stat = status;
        return stat;
    }

    
    
    
    
    function getTokenValue() public view returns (uint256 tokens) {
        C4FToken C4F = C4FToken(owner);
        return C4F.balanceOf(address(this));
    }

    
    
    
    function completeFavor() public onlyRequester returns (bool success) {
        
        require(provider != address(0));
        
        
        uint256 actTokenvalue = getTokenValue();
        C4FToken C4F = C4FToken(owner);
        if(!C4F.transferWithCommission(provider, actTokenvalue)) revert();
        closeTime = now;
        status = 3;
        favorCompleted(provider,actTokenvalue);
        return true;
    }

    
    
    
    
    
    function cancelFavor() public onlyRequester returns (bool success) {
        
        require((!providerLocked) || ((now > deadline.add(12*3600)) && (!providerCompleted) && (!providerDisputed)));
        
        require(status==1);
        
        uint256 actTokenvalue = getTokenValue();
        C4FToken C4F = C4FToken(owner);
        if(!C4F.transfer(requester,actTokenvalue)) revert();
        closeTime = now;
        status = 2;
        favorCancelled(actTokenvalue);
        return true;
    }
    
    
    
    
    
    function changeTokenOffer(uint256 newOffer) public onlyRequester returns (bool success) {
        
        require((!providerLocked) && (!providerDisputed) && (!providerCompleted));
        
        require(status==1);
        
        uint256 actTokenvalue = getTokenValue();
        require(newOffer < actTokenvalue);
        
        require(newOffer > 0);
        
        C4FToken C4F = C4FToken(owner);
        if(!C4F.transfer(requester, actTokenvalue.sub(newOffer))) revert();
        tokenOfferChanged(actTokenvalue,newOffer);
        return true;
    }
    
    
    
    
    
    
    
    
    function arbitrateC4FContract(uint8 percentReturned) public onlyOwner returns (bool success) {
        
        require((providerDisputed) || (requesterDisputed));
        
        uint256 actTokens = getTokenValue();
        
        
        uint256 arbitrationTokens = actTokens.mul(arbitrationCosts);
        arbitrationTokens = arbitrationTokens.div(100);
        
        actTokens = actTokens.sub(arbitrationTokens);
        
        
        uint256 requesterTokens = actTokens.mul(percentReturned);
        requesterTokens = requesterTokens.div(100);
        
        actTokens = actTokens.sub(requesterTokens);
        
        
        C4FToken C4F = C4FToken(owner);
        
        address commissionTarget = C4F.getCommissionTarget();
        
        if(!C4F.transfer(requester, requesterTokens)) revert();
        
        if(!C4F.transfer(provider, actTokens)) revert();
        
        if(!C4F.transfer(commissionTarget, arbitrationTokens)) revert();
        
        
        status = 4;
        closeTime = now;
        success = true;
        escrowArbitrated(provider,requesterTokens,arbitrationTokens);
        return success;
    }

}














