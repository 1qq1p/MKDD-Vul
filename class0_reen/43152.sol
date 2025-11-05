





pragma solidity ^0.4.24;





library SafeMath {

    function mul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal returns (uint) {
        
        uint c = a / b;
        
        return c;
    }

    function sub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a < b ? a : b;
    }

    function assert(bool assertion) internal {
        if (!assertion) {
            throw;
        }
    }

}







contract TokenTimelock {

    
    ERC20Basic token;

    
    address beneficiary;

    
    uint releaseTime;

    function TokenTimelock(ERC20Basic _token, address _beneficiary, uint _releaseTime) {
        require(_releaseTime > now);
        token = _token;
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
    }

    


    function claim() {
        require(msg.sender == beneficiary);
        require(now >= releaseTime);

        uint amount = token.balanceOf(this);
        require(amount > 0);

        token.transfer(beneficiary, amount);
    }

}






