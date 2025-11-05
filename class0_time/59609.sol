pragma solidity ^0.4.13;

contract WETH9_ {
    string public name     = "Wrapped Ether";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    function() public payable {
        deposit();
    }
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        Deposit(msg.sender, msg.value);
    }
    function withdraw(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        msg.sender.transfer(wad);
        Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return this.balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        Transfer(src, dst, wad);

        return true;
    }
}

interface FundInterface {

    

    event PortfolioContent(uint holdings, uint price, uint decimals);
    event RequestUpdated(uint id);
    event Invested(address indexed ofParticipant, uint atTimestamp, uint shareQuantity);
    event Redeemed(address indexed ofParticipant, uint atTimestamp, uint shareQuantity);
    event SpendingApproved(address onConsigned, address ofAsset, uint amount);
    event FeesConverted(uint atTimestamp, uint shareQuantityConverted, uint unclaimed);
    event CalculationUpdate(uint atTimestamp, uint managementFee, uint performanceFee, uint nav, uint sharePrice, uint totalSupply);
    event OrderUpdated(uint id);
    event LogError(uint ERROR_CODE);
    event ErrorMessage(string errorMessage);

    
    
    function requestInvestment(uint giveQuantity, uint shareQuantity, bool isNativeAsset) external;
    function requestRedemption(uint shareQuantity, uint receiveQuantity, bool isNativeAsset) external;
    function executeRequest(uint requestId) external;
    function cancelRequest(uint requestId) external;
    function redeemAllOwnedAssets(uint shareQuantity) external returns (bool);
    
    function enableInvestment() external;
    function disableInvestment() external;
    function enableRedemption() external;
    function disableRedemption() external;
    function shutDown() external;
    
    function makeOrder(uint exchangeId, address sellAsset, address buyAsset, uint sellQuantity, uint buyQuantity) external;
    function takeOrder(uint exchangeId, uint id, uint quantity) external;
    function cancelOrder(uint exchangeId, uint id) external;

    
    function emergencyRedeem(uint shareQuantity, address[] requestedAssets) public returns (bool success);
    
    function allocateUnclaimedFees();

    
    
    function getModules() view returns (address, address, address);
    function getLastOrderId() view returns (uint);
    function getLastRequestId() view returns (uint);
    function getNameHash() view returns (bytes32);
    function getManager() view returns (address);

    
    function performCalculations() view returns (uint, uint, uint, uint, uint, uint, uint);
    function calcSharePrice() view returns (uint);
}

interface AssetInterface {
    








    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    

    
    
    function transfer(address _to, uint _value, bytes _data) public returns (bool success);

    
    
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    
    function balanceOf(address _owner) view public returns (uint balance);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
}

interface ERC223Interface {
    function balanceOf(address who) constant returns (uint);
    function transfer(address to, uint value) returns (bool);
    function transfer(address to, uint value, bytes data) returns (bool);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}
