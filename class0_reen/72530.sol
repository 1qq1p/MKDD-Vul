














pragma solidity 0.4.24;


contract Rates is Restricted {
    using SafeMath for uint256;

    struct RateInfo {
        uint rate; 
                    
        uint lastUpdated;
    }

    
    mapping(bytes32 => RateInfo) public rates;

    event RateChanged(bytes32 symbol, uint newRate);

    constructor(address permissionGranterContract) public Restricted(permissionGranterContract) {} 

    function setRate(bytes32 symbol, uint newRate) external restrict("RatesFeeder") {
        rates[symbol] = RateInfo(newRate, now);
        emit RateChanged(symbol, newRate);
    }

    function setMultipleRates(bytes32[] symbols, uint[] newRates) external restrict("RatesFeeder") {
        require(symbols.length == newRates.length, "symobls and newRates lengths must be equal");
        for (uint256 i = 0; i < symbols.length; i++) {
            rates[symbols[i]] = RateInfo(newRates[i], now);
            emit RateChanged(symbols[i], newRates[i]);
        }
    }

    function convertFromWei(bytes32 bSymbol, uint weiValue) external view returns(uint value) {
        require(rates[bSymbol].rate > 0, "rates[bSymbol] must be > 0");
        return weiValue.mul(rates[bSymbol].rate).roundedDiv(1000000000000000000);
    }

    function convertToWei(bytes32 bSymbol, uint value) external view returns(uint weiValue) {
        
        require(rates[bSymbol].rate > 0, "rates[bSymbol] must be > 0");
        
        return value.mul(1000000000000000000).roundedDiv(rates[bSymbol].rate);
    }

}







pragma solidity 0.4.24;


interface TransferFeeInterface {
    function calculateTransferFee(address from, address to, uint amount) external view returns (uint256 fee);
}







pragma solidity 0.4.24;


interface ERC20Interface {
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event Transfer(address indexed from, address indexed to, uint amount);

    function transfer(address to, uint value) external returns (bool); 
    function transferFrom(address from, address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
    function balanceOf(address who) external view returns (uint);
    function allowance(address _owner, address _spender) external view returns (uint remaining);

}







pragma solidity 0.4.24;


interface TokenReceiver {
    function transferNotification(address from, uint256 amount, uint data) external;
}









pragma solidity 0.4.24;






