pragma solidity 0.4.23;







contract MozoSaleToken is BasicToken, Timeline, ChainCoOwner, ICO {
    using SafeMath for uint;

    
    string public constant name = "Mozo Sale Token";

    
    string public constant symbol = "SMZO";

    
    uint8 public constant decimals = 2;

    
    uint public constant AML_THRESHOLD = 16500000;

    
    uint public noBonusTokenRecipients;

    
    uint public totalBonusToken;

    
    mapping(address => bool) bonus_transferred_repicients;

    
    uint public constant MAX_TRANSFER = 80;

    
    uint public transferredIndex;

    
    bool public isCapped = false;

    
    uint public totalCapInWei;

    
    uint public rate;

    
    bool public isStopped;

    
    address[] public transferAddresses;

    
    mapping(address => bool) public whitelist;

    
    
    mapping(address => uint) public pendingAmounts;

    


    modifier onlyWhitelisted() {
        require(whitelist[msg.sender]);
        _;
    }

    


    modifier onlyOwnerOrCoOwner() {
        require(isValidOwner(msg.sender));
        _;
    }

    


    modifier onlyStopping() {
        require(isStopped == true);
        _;
    }

    


    modifier onlySameChain() {
        
        if (!isValidOwner(msg.sender)) {
            
            ChainOwner sm = ChainOwner(msg.sender);
            

            
            require(sm.owner() == owner());
        }
        _;
    }


    








    function MozoSaleToken(
        OwnerERC20 _mozoToken,
        address[] _coOwner,
        uint _supply,
        uint _rate,
        uint _openingTime,
        uint _closingTime
    )
    public
    ChainCoOwner(_mozoToken, _coOwner)
    Timeline(_openingTime, _closingTime)
    onlyOwner()
    {
        require(_supply > 0);
        require(_rate > 0);

        rate = _rate;
        totalSupply_ = _supply;

        
        balances[_mozoToken.owner()] = totalSupply_;

        
        addAddressToWhitelist(msg.sender);
        addAddressesToWhitelist(_coOwner);
        emit Transfer(0x0, _mozoToken.owner(), totalSupply_);
    }
    
    function addCoOwners(address[] _coOwner) public onlyOwner {
        _addCoOwners(_coOwner);
    }

    function addCoOwner(address _coOwner) public onlyOwner {
        _addCoOwner(_coOwner);
    }

    function disableCoOwners(address[] _coOwner) public onlyOwner {
        _disableCoOwners(_coOwner);
    }

    function disableCoOwner(address _coOwner) public onlyOwner {
        _disableCoOwner(_coOwner);
    }

    


    function getRate() public view returns (uint) {
        return rate;
    }

    



    function setRate(uint _rate) public onlyOwnerOrCoOwner {
        rate = _rate;
    }

    


    function isReachCapped() public view returns (bool) {
        return isCapped;
    }

    




    function addAddressToWhitelist(address _address) onlyOwnerOrCoOwner public returns (bool success) {
        if (!whitelist[_address]) {
            whitelist[_address] = true;
            
            uint noOfTokens = pendingAmounts[_address];
            if (noOfTokens > 0) {
                pendingAmounts[_address] = 0;
                transfer(_address, noOfTokens);
            }
            success = true;
        }
    }

    





    function addAddressesToWhitelist(address[] _addresses) onlyOwnerOrCoOwner public returns (bool success) {
        uint length = _addresses.length;
        for (uint i = 0; i < length; i++) {
            if (addAddressToWhitelist(_addresses[i])) {
                success = true;
            }
        }
    }

    





    function removeAddressFromWhitelist(address _address) onlyOwnerOrCoOwner public returns (bool success) {
        if (whitelist[_address]) {
            whitelist[_address] = false;
            success = true;
        }
    }

    





    function removeAddressesFromWhitelist(address[] _addresses) onlyOwnerOrCoOwner public returns (bool success) {
        uint length = _addresses.length;
        for (uint i = 0; i < length; i++) {
            if (removeAddressFromWhitelist(_addresses[i])) {
                success = true;
            }
        }
    }

    



    function setStop() onlyOwnerOrCoOwner {
        isStopped = true;
    }

    



    function setReachCapped() public onlyOwnerOrCoOwner {
        isCapped = true;
    }

    


    function getCapInWei() public view returns (uint) {
        return totalCapInWei;
    }

    


    function getNoInvestor() public view returns (uint) {
        return transferAddresses.length;
    }

    


    function getUnsoldToken() public view returns (uint) {
        uint unsold = balances[owner()];
        for (uint j = 0; j < coOwnerList.length; j++) {
            unsold = unsold.add(balances[coOwnerList[j]]);
        }

        return unsold;
    }

    


    function getDistributedToken() public view returns (uint) {
        return totalSupply_.sub(getUnsoldToken());
    }

    




    function transfer(address _to, uint _value) public returns (bool) {
        
        
        
        
        
        

        
        bool notAddToList = isValidOwner(_to) || (balances[_to] > 0);

        
        if (!isStopped) {
            if (!whitelist[_to]) {
                if ((_value + balances[_to]) > AML_THRESHOLD) {
                    pendingAmounts[_to] = pendingAmounts[_to].add(_value);
                    return true;
                }
            }
        }

        if (BasicToken.transfer(_to, _value)) {
            if (!notAddToList) {
                transferAddresses.push(_to);
            }
            return true;
        }

        return false;
    }

    



    function calculateNoToken(uint _weiAmount) public view returns (uint) {
        return _weiAmount.div(rate);
    }

    




    function transferByEth(address _to, uint _weiAmount, uint _value)
    public
    onlyWhileOpen
    onlySameChain()
    returns (bool)
    {
        if (transfer(_to, _value)) {
            totalCapInWei = totalCapInWei.add(_weiAmount);
            return true;
        }
        return false;
    }

    



    function release() public onlyOwnerOrCoOwner {
        _release();
    }

    


    function claim() public isEnded {
        require(balances[msg.sender] > 0);
        uint investorBalance = balances[msg.sender];

        balances[msg.sender] = 0;
        parent.transfer(msg.sender, investorBalance);
    }

    



    function bonusToken(address[] _recipients, uint[] _amount) public onlyOwnerOrCoOwner onlyStopping {
        uint len = _recipients.length;
        uint len1 = _amount.length;
        require(len == len1);
        require(len <= MAX_TRANSFER);
        uint i;
        uint total = 0;
        for (i = 0; i < len; i++) {
            if (bonus_transferred_repicients[_recipients[i]] == false) {
                bonus_transferred_repicients[_recipients[i]] = transfer(_recipients[i], _amount[i]);
                total = total.add(_amount[i]);
            }
        }
        totalBonusToken = totalBonusToken.add(total);
        noBonusTokenRecipients = noBonusTokenRecipients.add(len);
    }

    function min(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }

    



    function _release() internal {
        uint length = min(transferAddresses.length, transferredIndex + MAX_TRANSFER);
        uint i = transferredIndex;

        if (isCapped) {
            
            for (; i < length; i++) {
                address ad = transferAddresses[i];
                uint b = balances[ad];
                if (b == 0) {
                    continue;
                }

                balances[ad] = 0;
                
                parent.transfer(ad, b);
            }
        } else {
            uint unsold = getUnsoldToken();
            uint sold = totalSupply_.sub(unsold);

            if (sold <= 0) {
                
                return;
            }
            for (; i < length; i++) {
                ad = transferAddresses[i];
                
                
                
                
                
                b = balances[ad];
                if (b == 0) {
                    continue;
                }
                
                b = b.add(b.mul(unsold).div(sold));

                
                balances[ad] = 0;
                parent.transfer(ad, b);
            }
        }

        transferredIndex = i - 1;

        
        
        
    }

}