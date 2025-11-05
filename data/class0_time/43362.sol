pragma solidity ^0.4.24;








contract FreeFeeCoin is StandardToken {
    string public symbol;
    string public name;
    uint8 public decimals = 9;

    uint noOfTokens = 2500000000; 

    
    
    
    
    
    address internal vault;

    
    
    
    address internal owner;

    
    
    
    
    
    
    
    
    
    address internal admin;

    event OwnerChanged(address indexed previousOwner, address indexed newOwner);
    event VaultChanged(address indexed previousVault, address indexed newVault);
    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);
    event ReserveChanged(address indexed _address, uint amount);
    event Recalled(address indexed from, uint amount);

    
    event MsgAndValue(string message, bytes32 value);

    






    mapping(address => uint) public reserves;

    


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    


    modifier onlyVault() {
        require(msg.sender == vault);
        _;
    }

    


    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    


    modifier onlyAdminOrVault() {
        require(msg.sender == vault || msg.sender == admin);
        _;
    }

    


    modifier onlyOwnerOrVault() {
        require(msg.sender == owner || msg.sender == vault);
        _;
    }

    


    modifier onlyAdminOrOwner() {
        require(msg.sender == owner || msg.sender == admin);
        _;
    }

    


    modifier onlyAdminOrOwnerOrVault() {
        require(msg.sender == owner || msg.sender == vault || msg.sender == admin);
        _;
    }

    











    constructor (string _symbol, string _name, address _owner, address _admin, address _vault) public {
        require(bytes(_symbol).length > 0);
        require(bytes(_name).length > 0);

        totalSupply_ = noOfTokens * (10 ** uint(decimals));
        

        symbol = _symbol;
        name = _name;
        owner = _owner;
        admin = _admin;
        vault = _vault;

        balances[vault] = totalSupply_;
        emit Transfer(address(0), vault, totalSupply_);
    }

    









    function setReserve(address _address, uint _reserve) public onlyAdmin {
        require(_reserve <= totalSupply_);
        require(_address != address(0));

        reserves[_address] = _reserve;
        emit ReserveChanged(_address, _reserve);
    }

    



    function transfer(address _to, uint256 _value) public returns (bool) {
        
        require(balanceOf(msg.sender) - _value >= reserveOf(msg.sender));
        return super.transfer(_to, _value);
    }

    





    function setVault(address _newVault) public onlyOwner {
        require(_newVault != address(0));
        require(_newVault != vault);

        address _oldVault = vault;

        
        vault = _newVault;
        emit VaultChanged(_oldVault, _newVault);

        
        uint _value = balances[_oldVault];
        balances[_oldVault] = 0;
        balances[_newVault] = balances[_newVault].add(_value);

        
        allowed[_newVault][msg.sender] = 0;
        reserves[_newVault] = 0;
        emit Transfer(_oldVault, _newVault, _value);
    }

    



    function setOwner(address _newOwner) public onlyVault {
        require(_newOwner != address(0));
        require(_newOwner != owner);

        owner = _newOwner;
        emit OwnerChanged(owner, _newOwner);
    }

    



    function setAdmin(address _newAdmin) public onlyOwnerOrVault {
        require(_newAdmin != address(0));
        require(_newAdmin != admin);

        admin = _newAdmin;

        emit AdminChanged(admin, _newAdmin);
    }

    







    function recall(address _from, uint _amount) public onlyAdmin {
        require(_from != address(0));
        require(_amount > 0);

        uint currentReserve = reserveOf(_from);
        uint currentBalance = balanceOf(_from);

        require(currentReserve >= _amount);
        require(currentBalance >= _amount);

        uint newReserve = currentReserve - _amount;
        reserves[_from] = newReserve;
        emit ReserveChanged(_from, newReserve);

        
        balances[_from] = balances[_from].sub(_amount);
        balances[vault] = balances[vault].add(_amount);
        emit Transfer(_from, vault, _amount);

        emit Recalled(_from, _amount);
    }

    





    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[_from].sub(reserves[_from]));
        return super.transferFrom(_from, _to, _value);
    }

    function getOwner() public view onlyAdminOrOwnerOrVault returns (address) {
        return owner;
    }

    function getVault() public view onlyAdminOrOwnerOrVault returns (address) {
        return vault;
    }

    function getAdmin() public view onlyAdminOrOwnerOrVault returns (address) {
        return admin;
    }

    function getOneFreeFeeCoin() public view returns (uint) {
        return (10 ** uint(decimals));
    }

    function getMaxNumberOfTokens() public view returns (uint) {
        return noOfTokens;
    }

    


    function reserveOf(address _address) public view returns (uint _reserve) {
        return reserves[_address];
    }

    


    function reserve() public view returns (uint _reserve) {
        return reserves[msg.sender];
    }
}