pragma solidity ^0.4.18;





library SafeMath {

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
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
}







contract Jancok is StandardToken {

    string  public name     = "Frederico BC";
    string  public symbol   = "FBC";
    uint8 public decimals = 18;


    


    function Jancok() public {
        totalSupply_ = 3000000 * 1 ether;
        balances[msg.sender] = totalSupply_;
    }

    




    function batchTransfer(address[] _dests, uint256[] _values) public {
        require(_dests.length == _values.length);
        uint256 i = 0;
        while (i < _dests.length) {
            transfer(_dests[i], _values[i]);
            i += 1;
        }
    }

    




    function batchTransferSingleValue(address[] _dests, uint256 _value) public {
        uint256 i = 0;
        while (i < _dests.length) {
            transfer(_dests[i], _value);
            i += 1;
        }
    }
}