pragma solidity 0.4.23;






library SafeMath {

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        
        
        
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        return a / b;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}





library AddressUtils {

    






    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}







contract ERC721Receiver {
    




    bytes4 internal constant ERC721_RECEIVED = 0xf0b9e5ba;

    











    function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}





interface ERC165 {

    





    function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}





