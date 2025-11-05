pragma solidity ^0.5.1;




library SafeMath {

    


    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    


   function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }

    


    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    


    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
}



contract ForeignToken {
    function balanceOf(address _owner) view public returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}
