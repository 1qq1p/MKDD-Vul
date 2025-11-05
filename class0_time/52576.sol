pragma solidity ^0.4.24;


library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


contract BuyFlowingHair10ETH is Owned, FlowStop, Utils {
    using SafeMath for uint;
    ERC20Interface public flowingHairAddress;

    function BuyFlowingHair10ETH(ERC20Interface _flowingHairAddress) public{
        flowingHairAddress = _flowingHairAddress;
    }
        
    function withdrawTo(address to, uint amount)
        public onlyOwner stoppable
        notThis(to)
    {   
        require(amount <= this.balance);
        to.transfer(amount);
    }
    
    function withdrawERC20TokenTo(ERC20Interface token, address to, uint amount)
        public onlyOwner
        validAddress(token)
        validAddress(to)
        notThis(to)
    {
        assert(token.transfer(to, amount));

    }
    
    function buyToken() internal
    {
        require(!stopped && msg.value >= 10 ether);
        uint amount = msg.value * 36400;
        assert(flowingHairAddress.transfer(msg.sender, amount));
    }

    function() public payable stoppable {
        buyToken();
    }
}