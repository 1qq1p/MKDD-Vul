pragma solidity ^0.4.24;

library Address {

  






    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}

contract Delegate {

    function mint(address _sender, address _to) public returns (bool);

    function approve(address _sender, address _to, uint256 _tokenId) public returns (bool);

    function setApprovalForAll(address _sender, address _operator, bool _approved) public returns (bool);

    function transferFrom(address _sender, address _from, address _to, uint256 _tokenId) public returns (bool);
    
    function safeTransferFrom(address _sender, address _from, address _to, uint256 _tokenId) public returns (bool);

    function safeTransferFrom(address _sender, address _from, address _to, uint256 _tokenId, bytes memory _data) public returns (bool);

}





