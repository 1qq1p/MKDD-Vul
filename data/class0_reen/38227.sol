















                            
pragma solidity ^0.4.25;
contract safeApi{
    
   modifier safe(){
        address _addr = msg.sender;
        require (_addr == tx.origin,'Error Action!');
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "Sender not authorized!");
            _;
    }


    
 function toBytes(uint256 _num) internal returns (bytes _ret) {
   assembly {
        _ret := mload(0x10)
        mstore(_ret, 0x20)
        mstore(add(_ret, 0x20), _num)
    }
}

function subStr(string _s, uint start, uint end) internal pure returns (string){
        bytes memory s = bytes(_s);
        string memory copy = new string(end - start);

          uint k = 0;
        for (uint i = start; i < end; i++){ 
            bytes(copy)[k++] = bytes(_s)[i];
        }
        return copy;
    }
     

 function safePercent(uint256 a,uint256 b) 
      internal
      constant
      returns(uint256)
      {
        assert(a>0 && a <=100);
        return  div(mul(b,a),100);
      }
      
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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