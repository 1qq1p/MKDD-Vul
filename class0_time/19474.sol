pragma solidity 0.5.2;




interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract DxMath {
    
    function min(uint a, uint b) public pure returns (uint) {
        if (a < b) {
            return a;
        } else {
            return b;
        }
    }

    function atleastZero(int a) public pure returns (uint) {
        if (a < 0) {
            return 0;
        } else {
            return uint(a);
        }
    }
    
    
    
    
    
    function safeToAdd(uint a, uint b) public pure returns (bool) {
        return a + b >= a;
    }

    
    
    
    
    function safeToSub(uint a, uint b) public pure returns (bool) {
        return a >= b;
    }

    
    
    
    
    function safeToMul(uint a, uint b) public pure returns (bool) {
        return b == 0 || a * b / b == a;
    }

    
    
    
    
    function add(uint a, uint b) public pure returns (uint) {
        require(safeToAdd(a, b));
        return a + b;
    }

    
    
    
    
    function sub(uint a, uint b) public pure returns (uint) {
        require(safeToSub(a, b));
        return a - b;
    }

    
    
    
    
    function mul(uint a, uint b) public pure returns (uint) {
        require(safeToMul(a, b));
        return a * b;
    }
}


