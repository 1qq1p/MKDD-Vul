pragma solidity 0.4.19;






interface NokuPricingPlan {
    







    function payFee(bytes32 serviceName, uint256 multiplier, address client) public returns(bool paid);

    






    function usageFee(bytes32 serviceName, uint256 multiplier) public constant returns(uint fee);
}








contract NokuCustomERC20 is Ownable, DetailedERC20, MintableToken, BurnableToken {
    using SafeMath for uint256;

    event LogNokuCustomERC20Created(
        address indexed caller,
        string indexed name,
        string indexed symbol,
        uint8 decimals,
        address pricingPlan,
        address serviceProvider
    );
    event LogTransferFeePercentageChanged(address indexed caller, uint256 indexed transferFeePercentage);
    event LogPricingPlanChanged(address indexed caller, address indexed pricingPlan);

    
    address public serviceProvider;

    
    address public pricingPlan;

    
    uint256 public transferFeePercentage;

    bytes32 public constant CUSTOM_ERC20_BURN_SERVICE_NAME = "NokuCustomERC20.burn";
    bytes32 public constant CUSTOM_ERC20_MINT_SERVICE_NAME = "NokuCustomERC20.mint";

    


    modifier onlyServiceProvider() {
        require(msg.sender == serviceProvider);
        _;
    }

    function NokuCustomERC20(
        string _name,
        string _symbol,
        uint8 _decimals,
        address _pricingPlan,
        address _serviceProvider
    )
    DetailedERC20 (_name, _symbol, _decimals) public
    {
        require(bytes(_name).length > 0);
        require(bytes(_symbol).length > 0);
        require(_pricingPlan != 0);
        require(_serviceProvider != 0);

        pricingPlan = _pricingPlan;
        serviceProvider = _serviceProvider;

        LogNokuCustomERC20Created(
            msg.sender,
            _name,
            _symbol,
            _decimals,
            _pricingPlan,
            _serviceProvider
        );
    }

    function isCustomToken() public pure returns(bool isCustom) {
        return true;
    }

    



    function setTransferFeePercentage(uint256 _transferFeePercentage) public onlyOwner {
        require(0 <= _transferFeePercentage && _transferFeePercentage <= 100);
        require(_transferFeePercentage != transferFeePercentage);

        transferFeePercentage = _transferFeePercentage;

        LogTransferFeePercentageChanged(msg.sender, _transferFeePercentage);
    }

    



    function setPricingPlan(address _pricingPlan) public onlyServiceProvider {
        require(_pricingPlan != 0);
        require(_pricingPlan != pricingPlan);

        pricingPlan = _pricingPlan;

        LogPricingPlanChanged(msg.sender, _pricingPlan);
    }

    



    function transferFee(uint256 _value) public view returns (uint256 usageFee) {
        return _value.mul(transferFeePercentage).div(100);
    }

    


    function transfer(address _to, uint256 _value) public returns (bool transferred) {
        if (transferFeePercentage == 0) {
            return super.transfer(_to, _value);
        }
        else {
            uint256 usageFee = transferFee(_value);
            uint256 netValue = _value.sub(usageFee);

            bool feeTransferred = super.transfer(owner, usageFee);
            bool netValueTransferred = super.transfer(_to, netValue);

            return feeTransferred && netValueTransferred;
        }
    }

    


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool transferred) {
        if (transferFeePercentage == 0) {
            return super.transferFrom(_from, _to, _value);
        }
        else {
            uint256 usageFee = transferFee(_value);
            uint256 netValue = _value.sub(usageFee);

            bool feeTransferred = super.transferFrom(_from, owner, usageFee);
            bool netValueTransferred = super.transferFrom(_from, _to, netValue);

            return feeTransferred && netValueTransferred;
        }
    }

    



    function burn(uint256 _amount) public {
        require(_amount > 0);

        super.burn(_amount);

        require(NokuPricingPlan(pricingPlan).payFee(CUSTOM_ERC20_BURN_SERVICE_NAME, _amount, msg.sender));
    }

    





    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool minted) {
        require(_to != 0);
        require(_amount > 0);

        super.mint(_to, _amount);

        require(NokuPricingPlan(pricingPlan).payFee(CUSTOM_ERC20_MINT_SERVICE_NAME, _amount, msg.sender));

        return true;
    }
}