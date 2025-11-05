pragma solidity ^0.4.23;








contract TransferableToken is StandardToken,Ownable {

    



    event Transferable();
    event UnTransferable();

    bool public transferable = false;
    mapping (address => bool) public whitelisted;

    


    
    constructor() 
        StandardToken() 
        Ownable()
        public 
    {
        whitelisted[msg.sender] = true;
    }

    



    


    modifier whenNotTransferable() {
        require(!transferable);
        _;
    }

    


    modifier whenTransferable() {
        require(transferable);
        _;
    }

    


    modifier canTransfert() {
        if(!transferable){
            require (whitelisted[msg.sender]);
        } 
        _;
   }
   
    



    


    function allowTransfert() onlyOwner whenNotTransferable public {
        transferable = true;
        emit Transferable();
    }

    


    function restrictTransfert() onlyOwner whenTransferable public {
        transferable = false;
        emit UnTransferable();
    }

    


    function whitelist(address _address) onlyOwner public {
        require(_address != 0x0);
        whitelisted[_address] = true;
    }

    


    function restrict(address _address) onlyOwner public {
        require(_address != 0x0);
        whitelisted[_address] = false;
    }


    



    function transfer(address _to, uint256 _value) public canTransfert returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public canTransfert returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

  





    function approve(address _spender, uint256 _value) public canTransfert returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public canTransfert returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public canTransfert returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}































pragma solidity ^0.4.23;



