
pragma solidity 0.4.23;





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






contract NLCToken is StandardToken {
    
    using SafeMath for uint256;

    
    string public constant name = "Nutrilife OU";
    string public constant symbol = "NLC";
    uint8 public constant decimals = 18;  
    
    
    address public nlcAdminAddress;
    uint256 public weiRaised;
    uint256 public rate;

    modifier onlyAdmin {
        require(msg.sender == nlcAdminAddress);
        _;
    }
    
    




    event Investment(address indexed investor, uint256 value);
    event TokenPurchaseRequestFromInvestment(address indexed investor, uint256 token);
    event ApproveTokenPurchaseRequest(address indexed investor, uint256 token);
    
    
    uint256 public constant INITIAL_SUPPLY = 500000000 * 10**uint256(decimals);
    mapping(address => uint256) public _investorsVault;
    mapping(address => uint256) public _investorsInvestmentInToken;

    
    constructor(address _nlcAdminAddress, uint256 _rate) public {
        require(_nlcAdminAddress != address(0));
        
        nlcAdminAddress = _nlcAdminAddress;
        totalSupply_ = INITIAL_SUPPLY;
        rate = _rate;

        balances[_nlcAdminAddress] = totalSupply_;
    }


    


    function () external payable {
        investFund(msg.sender);
    }

    



    function investFund(address _investor) public payable {
        
        uint256 weiAmount = msg.value;
        
        _preValidatePurchase(_investor, weiAmount);
        
        weiRaised = weiRaised.add(weiAmount);
        
        _trackVault(_investor, weiAmount);
        
        _forwardFunds();

        emit Investment(_investor, weiAmount);
    }
    
    




    function investmentOf(address _investor) public view returns (uint256) {
        return _investorsVault[_investor];
    }

    




    function purchaseTokenFromInvestment(uint256 _ethInWei) public {
            
            require(_investorsVault[msg.sender] != 0);

            
            uint256 _token = _getTokenAmount(_ethInWei);
            
            _investorsVault[msg.sender] = _investorsVault[msg.sender].sub(_ethInWei);

            _investorsInvestmentInToken[msg.sender] = _investorsInvestmentInToken[msg.sender].add(_token);
            
            emit TokenPurchaseRequestFromInvestment(msg.sender, _token);
    }

    




    function tokenInvestmentRequest(address _investor) public view returns (uint256) {
        return _investorsInvestmentInToken[_investor];
    }

    




    function approveTokenInvestmentRequest(address _investor) public onlyAdmin {
        
        uint256 token = _investorsInvestmentInToken[_investor];
        require(token != 0);
        
        super.transfer(_investor, _investorsInvestmentInToken[_investor]);
        
        _investorsInvestmentInToken[_investor] = _investorsInvestmentInToken[_investor].sub(token);
        
        emit ApproveTokenPurchaseRequest(_investor, token);
    }

   




    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal pure {
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
        
        
        require(_weiAmount >= 0.5 ether);
    }

   




    function _trackVault(address _investor, uint256 _weiAmount) internal {
        _investorsVault[_investor] = _investorsVault[_investor].add(_weiAmount);
    }

    


    function _forwardFunds() internal {
        nlcAdminAddress.transfer(msg.value);
    }

    




    function _getTokenAmount(uint256 _weiAmount)
        internal view returns (uint256)
    {
        return _weiAmount.mul(rate).div(1 ether);
    }

}