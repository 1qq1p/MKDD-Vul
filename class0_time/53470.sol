pragma solidity ^0.4.21;

contract DLCToken is StandardToken, Configurable {

    string public constant name = "DoubleLand Coin";
    string public constant symbol = "DLC";
    uint32 public constant decimals = 18;

    uint256 public priceOfToken;

    bool tokenBeenInit = false;

    uint public constant percentRate = 100;
    uint public investorsTokensPercent;
    uint public foundersTokensPercent;
    uint public bountyTokensPercent;
    uint public developmentAuditPromotionTokensPercent;

    address public toSaleWallet;
    address public bountyWallet;
    address public foundersWallet;
    address public developmentAuditPromotionWallet;

    address public saleAgent;


    function DLCToken() public {
    }

    modifier notInit() {
        require(!tokenBeenInit);
        _;
    }

    function setSaleAgent(address newSaleAgent) public onlyConfigurerOrOwner{
        saleAgent = newSaleAgent;
    }

    function setPriceOfToken(uint256 newPriceOfToken) public onlyConfigurerOrOwner{
        priceOfToken = newPriceOfToken;
    }

    function setTotalSupply(uint256 _totalSupply) public notInit onlyConfigurer{
        totalSupply = _totalSupply;
    }

    function setFoundersTokensPercent(uint _foundersTokensPercent) public notInit onlyConfigurer{
        foundersTokensPercent = _foundersTokensPercent;
    }

    function setBountyTokensPercent(uint _bountyTokensPercent) public notInit onlyConfigurer{
        bountyTokensPercent = _bountyTokensPercent;
    }

    function setDevelopmentAuditPromotionTokensPercent(uint _developmentAuditPromotionTokensPercent) public notInit onlyConfigurer{
        developmentAuditPromotionTokensPercent = _developmentAuditPromotionTokensPercent;
    }

    function setBountyWallet(address _bountyWallet) public notInit onlyConfigurer{
        bountyWallet = _bountyWallet;
    }

    function setToSaleWallet(address _toSaleWallet) public notInit onlyConfigurer{
        toSaleWallet = _toSaleWallet;
    }

    function setFoundersWallet(address _foundersWallet) public notInit onlyConfigurer{
        foundersWallet = _foundersWallet;
    }

    function setDevelopmentAuditPromotionWallet(address _developmentAuditPromotionWallet) public notInit onlyConfigurer {
        developmentAuditPromotionWallet = _developmentAuditPromotionWallet;
    }

    function init() public notInit onlyConfigurer{
        require(totalSupply > 0);
        require(foundersTokensPercent > 0);
        require(bountyTokensPercent > 0);
        require(developmentAuditPromotionTokensPercent > 0);
        require(foundersWallet != address(0));
        require(bountyWallet != address(0));
        require(developmentAuditPromotionWallet != address(0));
        tokenBeenInit = true;

        investorsTokensPercent = percentRate - (foundersTokensPercent + bountyTokensPercent + developmentAuditPromotionTokensPercent);

        balances[toSaleWallet] = totalSupply.mul(investorsTokensPercent).div(percentRate);
        balances[foundersWallet] = totalSupply.mul(foundersTokensPercent).div(percentRate);
        balances[bountyWallet] = totalSupply.mul(bountyTokensPercent).div(percentRate);
        balances[developmentAuditPromotionWallet] = totalSupply.mul(developmentAuditPromotionTokensPercent).div(percentRate);
    }

    function getRestTokenBalance() public constant returns (uint256) {
        return balances[toSaleWallet];
    }

    function purchase(address beneficiary, uint256 qty) public {
        require(msg.sender == saleAgent || msg.sender == owner);
        require(beneficiary != address(0));
        require(qty > 0);
        require((getRestTokenBalance().sub(qty)) > 0);

        balances[beneficiary] = balances[beneficiary].add(qty);
        balances[toSaleWallet] = balances[toSaleWallet].sub(qty);

        emit Transfer(toSaleWallet, beneficiary, qty);
    }

    function () public payable {
        revert();
    }
}
