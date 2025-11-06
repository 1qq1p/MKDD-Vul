pragma solidity ^0.4.0;

contract Owned
{
    address creator = msg.sender;
    address owner01 = msg.sender;
    address owner02;
    address owner03;
    
    function
    isCreator()
    internal
    returns (bool)
    {
       return(msg.sender == creator);
    }
    
    function
    isOwner()
    internal
    returns (bool)
    {
        return(msg.sender == owner01 || msg.sender == owner02 || msg.sender == owner03);
    }

    event NewOwner(address indexed old, address indexed current);
    
    function
    setOwner(uint owner, address _addr)
    internal
    {
        if (address(0x0) != _addr)
        {
            if (isOwner() || isCreator())
            {
                if (0 == owner)
                {
                    NewOwner(owner01, _addr);
                    owner01 = _addr;
                }
                else if (1 == owner)
                {
                    NewOwner(owner02, _addr);
                    owner02 = _addr;
                }
                else {
                    NewOwner(owner03, _addr);
                    owner03 = _addr;
                }
            }
        }
    }
    
    function
    setOwnerOne(address _new)
    public
    {
        setOwner(0, _new);
    }
    
    function
    setOwnerTwo(address _new)
    public
    {
        setOwner(1, _new);
    }
    
    function
    setOwnerThree(address _new)
    public
    {
        setOwner(2, _new);
    }
}
