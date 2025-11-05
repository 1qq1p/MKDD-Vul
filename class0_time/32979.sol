pragma solidity ^0.4.23;



contract WhiteListed is Operatable {


    uint public count;
    mapping (address => bool) public whiteList;

    event Whitelisted(address indexed addr, uint whitelistedCount, bool isWhitelisted);

    function addWhiteListed(address[] addrs) external canOperate {
        uint c = count;
        for (uint i = 0; i < addrs.length; i++) {
            if (!whiteList[addrs[i]]) {
                whiteList[addrs[i]] = true;
                c++;
                emit Whitelisted(addrs[i], count, true);
            }
        }
        count = c;
    }

    function removeWhiteListed(address addr) external canOperate {
        require(whiteList[addr]);
        whiteList[addr] = false;
        count--;
        emit Whitelisted(addr, count, false);
    }

}