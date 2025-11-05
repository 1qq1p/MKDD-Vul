pragma solidity 0.4.24;







interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}







library SafeMath {
    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}














contract ERC1132 {
    


    mapping(address => bytes32[]) public lockReason;

    


    struct lockToken {
        uint256 amount;
        uint256 validity;
        bool claimed;
    }

    



    mapping(address => mapping(bytes32 => lockToken)) public locked;

    


    event Locked(
        address indexed account,
        bytes32 indexed reason,
        uint256 amount,
        uint256 validity
    );

    


    event Unlocked(
        address indexed account,
        bytes32 indexed reason,
        uint256 amount
    );

    






    function lock(bytes32 reason, uint256 amount, uint256 time)
        public returns (bool);

    






    function tokensLocked(address account, bytes32 reason)
        public view returns (uint256 amount);

    







    function tokensLockedAtTime(address account, bytes32 reason, uint256 time)
        public view returns (uint256 amount);

    



    function totalBalanceOf(address who)
        public view returns (uint256 amount);

    




    function extendLock(bytes32 reason, uint256 time)
        public returns (bool);

    




    function increaseLockAmount(bytes32 reason, uint256 amount)
        public returns (bool);

    




    function tokensUnlockable(address who, bytes32 reason)
        public view returns (uint256 amount);

    



    function unlock(address account)
        public returns (uint256 unlockableTokens);

    



    function getUnlockableTokens(address account)
        public view returns (uint256 unlockableTokens);

}


