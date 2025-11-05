pragma solidity ^0.4.21;

contract FeeCalculator is Ownable, SafeMath {

    uint public feeNumerator = 0;

    uint public feeDenominator = 0;

    uint public minFee = 0;

    uint public maxFee = 0;

    function setFee(uint _feeNumerator, uint _feeDenominator, uint _minFee, uint _maxFee) public onlyOwner {
        feeNumerator = _feeNumerator;
        feeDenominator = _feeDenominator;
        minFee = _minFee;
        maxFee = _maxFee;
    }

    function calculateFee(uint value) public view returns (uint requiredFee) {
        if (feeNumerator == 0 || feeDenominator == 0) return 0;

        uint fee = safeDiv(safeMul(value, feeNumerator), feeDenominator);

        if (fee < minFee) return minFee;

        if (fee > maxFee) return maxFee;

        return fee;
    }

    function subtractFee(uint value) internal returns (uint newValue);
}
