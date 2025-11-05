pragma solidity ^0.4.24;




library AddressUtilsLib {

    






    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }

        return size > 0;
    }
    
}

pragma solidity ^0.4.24;





library SafeMathLib {

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(0==b);
        uint256 c = a / b;
        
        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    


    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    


    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    


    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    


    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

pragma solidity ^0.4.24;







contract BasicToken is ERC20Basic {
    
    using SafeMathLib for uint256;
    using AddressUtilsLib for address;
    
    
    mapping(address => uint256) public balances;

    





    function _transfer(address _from,address _to, uint256 _value) public returns (bool){
        require(!_from.isContract());
        require(!_to.isContract());
        require(0 < _value);
        require(balances[_from] > _value);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    




    function transfer(address _to, uint256 _value) public returns (bool){
        return   _transfer(msg.sender,_to,_value);
    }

    

    




    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}
pragma solidity ^0.4.24;
