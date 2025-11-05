

pragma solidity 0.4.18;








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








contract ReleasableToken is StandardToken, Ownable {

    



    bool public released;

    


    address public releaseManager;

    


    mapping (address => bool) public isTransferManager;

    



    event ReleaseManagerSet(address addr);

    



    event TransferManagerApproved(address addr);

    



    event TransferManagerRevoked(address addr);

    


    event Released();

    


    modifier onlyTransferableFrom(address from) {
        if (!released) {
            require(isTransferManager[from]);
        }

        _;
    }

    


    modifier onlyTransferManager(address addr) {
        require(isTransferManager[addr]);
        _;
    }

    


    modifier onlyReleaseManager() {
        require(msg.sender == releaseManager);
        _;
    }

    


    modifier onlyReleased() {
        require(released);
        _;
    }

    


    modifier onlyNotReleased() {
        require(!released);
        _;
    }

    



    function setReleaseManager(address addr)
        public
        onlyOwner
        onlyNotReleased
    {
        releaseManager = addr;

        ReleaseManagerSet(addr);
    }

    



    function approveTransferManager(address addr)
        public
        onlyOwner
        onlyNotReleased
    {
        isTransferManager[addr] = true;

        TransferManagerApproved(addr);
    }

    



    function revokeTransferManager(address addr)
        public
        onlyOwner
        onlyTransferManager(addr)
        onlyNotReleased
    {
        delete isTransferManager[addr];

        TransferManagerRevoked(addr);
    }

    


    function release()
        public
        onlyReleaseManager
        onlyNotReleased
    {
        released = true;

        Released();
    }

    





    function transfer(
        address to,
        uint256 amount
    )
        public
        onlyTransferableFrom(msg.sender)
        returns (bool)
    {
        return super.transfer(to, amount);
    }

    






    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
        public
        onlyTransferableFrom(from)
        returns (bool)
    {
        return super.transferFrom(from, to, amount);
    }
}
















