pragma solidity ^0.4.24;
contract DSSToken is ERC20,owned{

    mapping(address =>bool)public frozenAccount;

    event AddSupply(uint256 amount);
    event FrozenFunds(address target, bool frozen);
    event Burn(address target,uint256 amount);

    constructor(string _name) ERC20(_name) public{
    }

    function mine(address target, uint256 amount) public onlyOwner{
        require(balanceOf[target]+amount >= balanceOf[target]);
        totalSupply += amount;
        balanceOf[target] += amount;

        emit AddSupply(amount);
        emit Transfer(0,target,amount);
    }

    function freezeAccount(address target,bool freeze) public onlyOwner{
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

     function burn(uint256 _value) public returns (bool success){
        require(balanceOf[msg.sender]>= _value);
        totalSupply -= _value;
        balanceOf[msg.sender] -= _value;
        emit Burn(msg.sender,_value);
        return true;
     }

     function burnFrom(address _from,uint256 _value) public returns (bool success){
        require(balanceOf[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);

        totalSupply -= _value;
        balanceOf[msg.sender] -= _value;
        allowed[_from][msg.sender] -= _value;

        emit Burn(msg.sender,_value);
        return true;
     }
}