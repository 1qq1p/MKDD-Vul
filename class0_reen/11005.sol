pragma solidity ^0.4.15;




library QuickMafs {
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a * _b;
        assert(_a == 0 || c / _a == _b);
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b > 0); 
        uint256 c = _a / _b;
        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        assert(c >= _a);
        return c;
    }
}





contract Ownable {

     

 
     address public owner;
    
     


     function Ownable() public {
         owner = msg.sender;
     }
    
    


     modifier onlyOwner(){
         require(msg.sender == owner);
         _; 
     }
    
    


    function transferOwnership(address _newOwner) public onlyOwner {
    
        
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }
}




