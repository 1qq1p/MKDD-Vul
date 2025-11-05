pragma solidity ^0.4.15;






contract HasNoEther is Ownable {

    






    function HasNoEther() payable {
        require(msg.value == 0);
    }

    


    function() external {
    }

    


    function reclaimEther() external onlyOwner {
        assert(owner.send(this.balance));
    }
}





library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}



