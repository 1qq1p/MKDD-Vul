

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



pragma solidity ^0.5.0;









library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}



pragma solidity ^0.5.0;

contract Factory is IFactory, SingletonHash {
    constructor(
        address _liability,
        address _lighthouse,
        DutchAuction _auction,
        AbstractENS _ens,
        XRT _xrt
    ) public {
        liabilityCode = _liability;
        lighthouseCode = _lighthouse;
        auction = _auction;
        ens = _ens;
        xrt = _xrt;
    }

    address public liabilityCode;
    address public lighthouseCode;

    using SafeERC20 for XRT;
    using SafeERC20 for ERC20;
    using SharedCode for address;

    


    DutchAuction public auction;

    


    AbstractENS public ens;

    


    XRT public xrt;

    





    function smma(uint256 _prePrice, uint256 _price) internal pure returns (uint256) {
        return (_prePrice * (smmaPeriod - 1) + _price) / smmaPeriod;
    }

    


    uint256 private constant smmaPeriod = 1000;

    


    function wnFromGas(uint256 _gas) public view returns (uint256) {
        
        if (auction.finalPrice() == 0)
            return _gas;

        
        uint256 epoch = totalGasConsumed / gasEpoch;

        
        uint256 wn = _gas * 10**9 * gasPrice * 2**epoch / 3**epoch / auction.finalPrice();

        
        return wn < _gas ? _gas : wn;
    }

    modifier onlyLighthouse {
        require(isLighthouse[msg.sender]);

        _;
    }

    modifier gasPriceEstimate {
        gasPrice = smma(gasPrice, tx.gasprice);

        _;
    }

    function createLighthouse(
        uint256 _minimalStake,
        uint256 _timeoutInBlocks,
        string  calldata _name
    )
        external
        returns (ILighthouse lighthouse)
    {
        bytes32 LIGHTHOUSE_NODE
            
            = 0x8d6c004b56cbe83bbfd9dcbd8f45d1f76398267bbb130a4629d822abc1994b96;
        bytes32 hname = keccak256(bytes(_name));

        
        bytes32 subnode = keccak256(abi.encodePacked(LIGHTHOUSE_NODE, hname));
        require(ens.resolver(subnode) == address(0));

        
        lighthouse = ILighthouse(lighthouseCode.proxy());
        require(Lighthouse(address(lighthouse)).setup(xrt, _minimalStake, _timeoutInBlocks));

        emit NewLighthouse(address(lighthouse), _name);
        isLighthouse[address(lighthouse)] = true;

        
        ens.setSubnodeOwner(LIGHTHOUSE_NODE, hname, address(this));

        
        AbstractResolver resolver = AbstractResolver(ens.resolver(LIGHTHOUSE_NODE));
        ens.setResolver(subnode, address(resolver));
        resolver.setAddr(subnode, address(lighthouse));
    }

    function createLiability(
        bytes calldata _demand,
        bytes calldata _offer
    )
        external
        onlyLighthouse
        returns (ILiability liability)
    {
        
        liability = ILiability(liabilityCode.proxy());
        require(Liability(address(liability)).setup(xrt));

        emit NewLiability(address(liability));

        
        (bool success, bytes memory returnData)
            = address(liability).call(abi.encodePacked(bytes4(0x48a984e4), _demand)); 
        require(success);
        singletonHash(liability.demandHash());
        nonceOf[liability.promisee()] += 1;

        (success, returnData)
            = address(liability).call(abi.encodePacked(bytes4(0x413781d2), _offer)); 
        require(success);
        singletonHash(liability.offerHash());
        nonceOf[liability.promisor()] += 1;

        
        require(isLighthouse[liability.lighthouse()]);

        
        if (liability.lighthouseFee() > 0)
            xrt.safeTransferFrom(liability.promisor(),
                                 tx.origin,
                                 liability.lighthouseFee());

        
        ERC20 token = ERC20(liability.token());
        if (liability.cost() > 0)
            token.safeTransferFrom(liability.promisee(),
                                   address(liability),
                                   liability.cost());

        
        if (liability.validator() != address(0) && liability.validatorFee() > 0)
            xrt.safeTransferFrom(liability.promisee(),
                                 address(liability),
                                 liability.validatorFee());
     }

    function liabilityCreated(
        ILiability _liability,
        uint256 _gas
    )
        external
        onlyLighthouse
        gasPriceEstimate
        returns (bool)
    {
        address liability = address(_liability);
        totalGasConsumed         += _gas;
        gasConsumedOf[liability] += _gas;
        return true;
    }

    function liabilityFinalized(
        ILiability _liability,
        uint256 _gas
    )
        external
        onlyLighthouse
        gasPriceEstimate
        returns (bool)
    {
        address liability = address(_liability);
        totalGasConsumed         += _gas;
        gasConsumedOf[liability] += _gas;
        require(xrt.mint(tx.origin, wnFromGas(gasConsumedOf[liability])));
        return true;
    }
}