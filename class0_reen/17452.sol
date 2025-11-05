pragma solidity ^0.4.18;

contract TrueUSD is StandardDelegate, PausableToken, BurnableToken, NoOwner, CanDelegate {
    string public name = "TrueUSD";
    string public symbol = "TUSD";
    uint8 public constant decimals = 18;

    AddressList public canReceiveMintWhiteList;
    AddressList public canBurnWhiteList;
    AddressList public blackList;
    AddressList public noFeesList;
    uint256 public burnMin = 10000 * 10**uint256(decimals);
    uint256 public burnMax = 20000000 * 10**uint256(decimals);

    uint80 public transferFeeNumerator = 7;
    uint80 public transferFeeDenominator = 10000;
    uint80 public mintFeeNumerator = 0;
    uint80 public mintFeeDenominator = 10000;
    uint256 public mintFeeFlat = 0;
    uint80 public burnFeeNumerator = 0;
    uint80 public burnFeeDenominator = 10000;
    uint256 public burnFeeFlat = 0;
    address public staker;

    event ChangeBurnBoundsEvent(uint256 newMin, uint256 newMax);
    event Mint(address indexed to, uint256 amount);
    event WipedAccount(address indexed account, uint256 balance);

    function TrueUSD() public {
        totalSupply_ = 0;
        staker = msg.sender;
    }

    function setLists(AddressList _canReceiveMintWhiteList, AddressList _canBurnWhiteList, AddressList _blackList, AddressList _noFeesList) onlyOwner public {
        canReceiveMintWhiteList = _canReceiveMintWhiteList;
        canBurnWhiteList = _canBurnWhiteList;
        blackList = _blackList;
        noFeesList = _noFeesList;
    }

    function changeName(string _name, string _symbol) onlyOwner public {
        name = _name;
        symbol = _symbol;
    }

    
    
    function burn(uint256 _value) public {
        require(canBurnWhiteList.onList(msg.sender));
        require(_value >= burnMin);
        require(_value <= burnMax);
        uint256 fee = payStakingFee(msg.sender, _value, burnFeeNumerator, burnFeeDenominator, burnFeeFlat, 0x0);
        uint256 remaining = _value.sub(fee);
        super.burn(remaining);
    }

    
    
    function mint(address _to, uint256 _amount) onlyOwner public {
        require(canReceiveMintWhiteList.onList(_to));
        totalSupply_ = totalSupply_.add(_amount);
        balances.addBalance(_to, _amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        payStakingFee(_to, _amount, mintFeeNumerator, mintFeeDenominator, mintFeeFlat, 0x0);
    }

    
    
    
    
    
    
    function changeBurnBounds(uint newMin, uint newMax) onlyOwner public {
        require(newMin <= newMax);
        burnMin = newMin;
        burnMax = newMax;
        ChangeBurnBoundsEvent(newMin, newMax);
    }

    
    
    function transferAllArgsNoAllowance(address _from, address _to, uint256 _value) internal {
        require(!blackList.onList(_from));
        require(!blackList.onList(_to));
        super.transferAllArgsNoAllowance(_from, _to, _value);
        payStakingFee(_to, _value, transferFeeNumerator, transferFeeDenominator, 0, _from);
    }

    function wipeBlacklistedAccount(address account) public onlyOwner {
        require(blackList.onList(account));
        uint256 oldValue = balanceOf(account);
        balances.setBalance(account, 0);
        totalSupply_ = totalSupply_.sub(oldValue);
        WipedAccount(account, oldValue);
    }

    function payStakingFee(address payer, uint256 value, uint80 numerator, uint80 denominator, uint256 flatRate, address otherParticipant) private returns (uint256) {
        if (noFeesList.onList(payer) || noFeesList.onList(otherParticipant)) {
            return 0;
        }
        uint256 stakingFee = value.mul(numerator).div(denominator).add(flatRate);
        if (stakingFee > 0) {
            super.transferAllArgsNoAllowance(payer, staker, stakingFee);
        }
        return stakingFee;
    }

    function changeStakingFees(uint80 _transferFeeNumerator,
                                 uint80 _transferFeeDenominator,
                                 uint80 _mintFeeNumerator,
                                 uint80 _mintFeeDenominator,
                                 uint256 _mintFeeFlat,
                                 uint80 _burnFeeNumerator,
                                 uint80 _burnFeeDenominator,
                                 uint256 _burnFeeFlat) public onlyOwner {
        require(_transferFeeDenominator != 0);
        require(_mintFeeDenominator != 0);
        require(_burnFeeDenominator != 0);
        transferFeeNumerator = _transferFeeNumerator;
        transferFeeDenominator = _transferFeeDenominator;
        mintFeeNumerator = _mintFeeNumerator;
        mintFeeDenominator = _mintFeeDenominator;
        mintFeeFlat = _mintFeeFlat;
        burnFeeNumerator = _burnFeeNumerator;
        burnFeeDenominator = _burnFeeDenominator;
        burnFeeFlat = _burnFeeFlat;
    }

    function changeStaker(address newStaker) public onlyOwner {
        require(newStaker != address(0));
        staker = newStaker;
    }
}





library NewSafeMath {

    


    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        
        
        
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    


    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); 
        uint256 c = _a / _b;
        

        return c;
    }

    


    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    


    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}






  


