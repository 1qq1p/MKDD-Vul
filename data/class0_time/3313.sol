

















pragma solidity ^0.4.23;







contract Consts {
    uint public constant TOKEN_DECIMALS = 18;
    uint8 public constant TOKEN_DECIMALS_UINT8 = 18;
    uint public constant TOKEN_DECIMAL_MULTIPLIER = 10 ** TOKEN_DECIMALS;

    string public constant TOKEN_NAME = "MULA";
    string public constant TOKEN_SYMBOL = "MULA";
    bool public constant PAUSED = false;
    address public constant TARGET_USER = 0xf49a977FDb82A20351e0b16f9fB5184cf7EFA15B;
    
    bool public constant CONTINUE_MINTING = false;
}



