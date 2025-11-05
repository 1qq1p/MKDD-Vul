































pragma solidity ^0.4.20;

contract TokenState is Owned {

    
    
    address public associatedContract;

    
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function TokenState(address _owner, address _associatedContract)
        Owned(_owner)
        public
    {
        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }

    

    
    function setAssociatedContract(address _associatedContract)
        external
        onlyOwner
    {
        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }

    function setAllowance(address tokenOwner, address spender, uint value)
        external
        onlyAssociatedContract
    {
        allowance[tokenOwner][spender] = value;
    }

    function setBalanceOf(address account, uint value)
        external
        onlyAssociatedContract
    {
        balanceOf[account] = value;
    }


    

    modifier onlyAssociatedContract
    {
        require(msg.sender == associatedContract);
        _;
    }

    

    event AssociatedContractUpdated(address _associatedContract);
}























