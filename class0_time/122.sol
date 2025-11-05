
pragma solidity ^0.4.24;

library ExtendedMath {
    function limitLessThan(uint a, uint b) internal pure returns(uint c) {
        if (a > b) return b;
        return a;
    }
}

library SafeMath {

    


    function mul(uint256 _a, uint256 _b) internal pure returns(uint256) {
        
        
        
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    


    function div(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b > 0); 
        uint256 c = _a / _b;
        

        return c;
    }

    


    function sub(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    


    function add(uint256 _a, uint256 _b) internal pure returns(uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b != 0);
        return a % b;
    }
}

contract CaelumFundraise is Ownable, BasicToken, abstractCaelum {

    





    uint AMOUNT_FOR_MASTERNODE = 50 ether;
    uint SPOTS_RESERVED = 10;
    uint COUNTER;
    bool fundraiseClosed = false;

    




    function() payable public {
        require(msg.value == AMOUNT_FOR_MASTERNODE && msg.value != 0);
        receivedFunds();
    }

    


    function buyMasternode () payable public {
        require(msg.value == AMOUNT_FOR_MASTERNODE && msg.value != 0);
        receivedFunds();
    }

    


    function receivedFunds() internal {
        require(!fundraiseClosed);
        require (COUNTER <= SPOTS_RESERVED);
        owner.transfer(msg.value);
        addMasternode(msg.sender);
    }

}
