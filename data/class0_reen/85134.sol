pragma solidity 0.4.19;






library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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






contract OCGFee is Ownable {

    SellableToken public sellableToken;

    using SafeMath for uint256;

    uint256 public offPeriod = 3 years;

    uint256 public offThreshold;

    uint256 public feeAmount;

    address public feeAddress;

    address public transferFeeAddress;

    uint256 public transferFee;

    modifier onlySellableContract() {
        require(msg.sender == address(sellableToken));
        _;
    }

    function OCGFee(
        uint256 _offThreshold,
        address _feeAddress,
        uint256 _feeAmount,
        address _transferFeeAddress,
        uint256 _transferFee 
    )
        public
    {
        require(_feeAddress != address(0) && _feeAmount >= 0 && _offThreshold > 0);
        offThreshold = _offThreshold;
        feeAddress = _feeAddress;
        feeAmount = _feeAmount;

        require(_transferFeeAddress != address(0) && _transferFee >= 0);
        transferFeeAddress = _transferFeeAddress;
        transferFee = _transferFee;
    }

    function setSellableToken(address _sellable) public onlyOwner {
        require(_sellable != address(0));
        sellableToken = SellableToken(_sellable);
    }

    function setStorageFee(
        uint256 _offThreshold,
        address _feeAddress,
        uint256 _feeAmount 
    ) public onlyOwner {
        require(_feeAddress != address(0));

        offThreshold = _offThreshold;
        feeAddress = _feeAddress;
        feeAmount = _feeAmount;
    }

    function decreaseThreshold(uint256 _value) public onlySellableContract {
        if (offThreshold < _value) {
            offThreshold = 0;
        } else {
            offThreshold = offThreshold.sub(_value);
        }
    }

    function setTransferFee(address _transferFeeAddress, uint256 _transferFee) public onlyOwner returns (bool) {
        if (_transferFeeAddress != address(0) && _transferFee >= 0) {
            transferFeeAddress = _transferFeeAddress;
            transferFee = _transferFee;

            return true;
        }

        return false;
    }

}
