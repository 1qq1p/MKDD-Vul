


















pragma solidity ^0.4.18;








contract ReentryProtected
{
    
    bool __reMutex;

    
    modifier preventReentry() {
        require(!__reMutex);
        __reMutex = true;
        _;
        delete __reMutex;
    }

    
    modifier noReentry() {
        require(!__reMutex);
        _;
    }
}
