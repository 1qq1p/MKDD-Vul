

















pragma solidity ^0.4.23;







contract Consts {
    uint public constant TOKEN_DECIMALS = 18;
    uint8 public constant TOKEN_DECIMALS_UINT8 = 18;
    uint public constant TOKEN_DECIMAL_MULTIPLIER = 10 ** TOKEN_DECIMALS;

    string public constant TOKEN_NAME = "PalladiumTokenMagic";
    string public constant TOKEN_SYMBOL = "PTMX";
    bool public constant PAUSED = true;
    address public constant TARGET_USER = 0xdF15E9399B9F325D161c38F7f2aFd72C11a19500;
    
    uint public constant START_TIME = 1533081600;
    
    bool public constant CONTINUE_MINTING = true;
}








