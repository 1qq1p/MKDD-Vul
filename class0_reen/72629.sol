

pragma solidity ^0.5.0;





library SafeMath {
    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}









pragma solidity 0.5.0;







library TaxLib
{
    using SafeMath for uint256;

    


    struct DynamicTax
    {
        


        uint256 amount;

        



        uint256 shift;
    }

    







    function applyTax(uint256 taxAmount, uint256 shift, uint256 value) internal pure returns (uint256)
    {
        uint256 temp = value.mul(taxAmount);

        return temp.div(shift);
    }

    




    function normalizeShiftAmount(uint256 shift) internal pure returns (uint256)
    {
        require(shift >= 0 && shift <= 2, "You can't set more than 2 decimal places");

        uint256 value = 100;

        return value.mul(10 ** shift);
    }
}









pragma solidity 0.5.0;








library VestingLib
{
    using SafeMath for uint256;

    


    uint256 private constant _timeShiftPeriod = 60 days;

    struct TeamMember
    {
        


        uint256 nextWithdrawal;

        


        uint256 totalRemainingAmount;

        



        uint256 firstTransferValue;

        



        uint256 eachTransferValue;

        


        bool active;
    }

    





    function _calculateMemberEarnings(uint256 tokenAmount) internal pure returns (uint256, uint256)
    {
        
        uint256 firstTransfer = TaxLib.applyTax(20, 100, tokenAmount);

        
        uint256 eachMonthTransfer = TaxLib.applyTax(10, 100, tokenAmount.sub(firstTransfer));

        return (firstTransfer, eachMonthTransfer);
    }

    




    function _updateNextWithdrawalTime(uint256 oldWithdrawal) internal view returns (uint256)
    {
        uint currentTimestamp = block.timestamp;

        require(oldWithdrawal <= currentTimestamp, "You need to wait the next withdrawal period");

        



        if (oldWithdrawal == 0)
        {
            return _timeShiftPeriod.add(currentTimestamp);
        }

        



        return oldWithdrawal.add(_timeShiftPeriod);
    }

    





    function _checkAmountForPay(TeamMember memory member) internal pure returns (uint256)
    {
        


        if (member.nextWithdrawal == 0)
        {
            return member.firstTransferValue;
        }

        


        return member.eachTransferValue >= member.totalRemainingAmount
            ? member.totalRemainingAmount
            : member.eachTransferValue;
    }
}



pragma solidity ^0.5.0;





interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.5.0;















contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    



    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    


    function owner() public view returns (address) {
        return _owner;
    }

    


    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    


    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    





    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    



    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    



    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}









pragma solidity 0.5.0;







