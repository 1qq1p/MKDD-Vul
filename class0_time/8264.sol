pragma solidity ^0.4.15;









contract InputValidator {

    


    modifier safe_arguments(uint _numArgs) {
        assert(msg.data.length == _numArgs * 32 + 4);
        _;
    }
}









