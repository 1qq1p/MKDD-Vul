pragma solidity ^0.5.2;

contract IERC721Receiver {
    













    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}

library Counters {
    using SafeMath for uint256;

    struct Counter {
        
        
        
        uint256 _value; 
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}
