pragma solidity ^0.4.24;


library SafeMath {

    


    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        
        
        
        if (_a == 0) {
            return 0;
        }

        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    


    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        
        
        
        return _a / _b;
    }

    


    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

    


    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }
}

contract JavvyToken is DetailedERC20, StandardToken, Ownable, Config {
    address public crowdsaleAddress;
    address public bonusAddress;
    address public multiSigAddress;

    constructor(
        string _name,
        string _symbol,
        uint8 _decimals
    ) public
    DetailedERC20(_name, _symbol, _decimals) {
        require(
            jvySupply == saleSupply + bonusSupply,
            "Sum of provided supplies is not equal to declared total Javvy supply. Check config!"
        );
        totalSupply_ = tokenToDecimals(jvySupply);
    }

    function initializeBalances(
        address _crowdsaleAddress,
        address _bonusAddress,
        address _multiSigAddress
    ) public
    onlyOwner() {
        crowdsaleAddress = _crowdsaleAddress;
        bonusAddress = _bonusAddress;
        multiSigAddress = _multiSigAddress;

        _initializeBalance(_crowdsaleAddress, saleSupply);
        _initializeBalance(_bonusAddress, bonusSupply);
    }

    function _initializeBalance(address _address, uint256 _supply) private {
        require(_address != address(0), "Address cannot be equal to 0x0!");
        require(_supply != 0, "Supply cannot be equal to 0!");
        balances[_address] = tokenToDecimals(_supply);
        emit Transfer(address(0), _address, _supply);
    }

    function tokenToDecimals(uint256 _amount) private view returns (uint256){
        
        return _amount * (10 ** 12);
    }

    function getRemainingSaleTokens() external view returns (uint256) {
        return balanceOf(crowdsaleAddress);
    }

}
